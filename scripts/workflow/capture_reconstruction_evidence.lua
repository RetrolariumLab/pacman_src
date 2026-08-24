-- Focused evidence capture for resolved reverse-engineering findings.

local output_path = assert(os.getenv("PACMAN_RECONSTRUCTION_EVIDENCE_TRACE"))
local scenario = assert(os.getenv("PACMAN_RECONSTRUCTION_EVIDENCE_SCENARIO"))
local max_frames = assert(tonumber(os.getenv("PACMAN_RECONSTRUCTION_EVIDENCE_MAX_FRAMES")))
local output = assert(io.open(output_path, "w"))

local SCRIPT = 0x003F
local BUTTONS = 0x004D
local PAUSE = 0x004A
local SHARED = 0x0087
local ROUND_STATE = 0x00C0
local RELEASE_GATE = 0x00D2
local SFX = 0x0600
local CHANNEL_INDEX = 0x00FC

local function symbol(name)
    local address = debugger.getsymboloffset(name)
    assert(address ~= nil and address >= 0, "missing debugger symbol: " .. name)
    return address
end

local function byte(address) return memory.readbyte(address) end
local function reg(name) return memory.getregister(name) or 0 end
local function emit(event, address, value, detail)
    output:write(string.format(
        "%d,%s,%04X,%04X,%02X,%02X,%02X,%02X,%02X,%s\n",
        emu.framecount(), event, address or 0, reg("pc"), byte(SCRIPT),
        value or 0, reg("a"), reg("x"), reg("y"), detail or ""))
    output:flush()
end

local seen = {}
local function emit_once(event, address, value, detail)
    local key = string.format("%s:%04X:%04X:%02X:%02X:%02X:%02X:%s", event,
        address, reg("pc"), byte(SCRIPT), value or 0, reg("x"), reg("y"),
        detail or "")
    if seen[key] then return end
    seen[key] = true
    emit(event, address, value, detail)
end

local function watch_reads(address, size, label)
    for offset = 0, size - 1 do
        local current = address + offset
        memory.registerread(current, function()
            emit_once("read", current, byte(current), label)
        end)
    end
end

local function watch_writes(address, size, label)
    for offset = 0, size - 1 do
        local current = address + offset
        memory.registerwrite(current, function()
            emit_once("write", current, reg("a"), label)
        end)
    end
end

output:write("frame,event,address,pc,script,value,a,x,y,detail\n")
emit("trace_start", 0, 0, scenario)

watch_reads(ROUND_STATE, 1, "RAM-001")
watch_writes(ROUND_STATE, 1, "RAM-001")
watch_reads(SHARED, 4, "RAM-002")
watch_writes(SHARED, 4, "RAM-002")
watch_reads(RELEASE_GATE, 1, "RAM-003")
watch_writes(RELEASE_GATE, 1, "RAM-003")
watch_writes(SFX, 16, "SND-001")

memory.registerexecute(symbol("bra_channel_has_active_stream"), function()
    local slot = byte(CHANNEL_INDEX)
    emit_once("sound_slot_active", SFX + slot, byte(SFX + slot),
        string.format("slot_%02X", slot))
end)

memory.registerexecute(symbol("bra_copy_optional_sprite_strip"), function()
    emit("attract_strip", symbol("tbl_attract_sprite_strip_data"),
        byte(SHARED), "DATA-003")
end)

memory.registerexecute(symbol("sub_try_reverse_ghost_directions"), function()
    emit("reversal_entry", RELEASE_GATE, byte(RELEASE_GATE),
        string.format("mask_%02X_phase_%02X", byte(SHARED + 1), byte(0x00D0)))
end)

local pause_phase = 0
memory.registerexecute(symbol("handler_script04_pause_handler"), function()
    if scenario ~= "pause-probe" or emu.framecount() < 22000 then return end
    if pause_phase == 0 then
        local previous = byte(BUTTONS)
        memory.writebyte(BUTTONS, bit.bor(previous, 0x08))
        emit("controlled_patch", BUTTONS, previous, "pause_press")
        pause_phase = 1
    elseif pause_phase == 1 and byte(PAUSE) % 2 == 1 and byte(SFX + 15) == 0 then
        local previous = byte(BUTTONS)
        memory.writebyte(BUTTONS, bit.bor(previous, 0x08))
        emit("controlled_patch", BUTTONS, previous, "resume_press")
        pause_phase = 2
    end
end)

while emu.framecount() < max_frames do emu.frameadvance() end

emit("trace_end", 0, 0, scenario)
output:close()
emu.exit()
