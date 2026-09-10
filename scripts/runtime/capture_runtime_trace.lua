-- Compact semantic runtime trace for roadmap milestone 7.

local output_path = assert(os.getenv("PACMAN_RUNTIME_TRACE"))
local scenario = assert(os.getenv("PACMAN_RUNTIME_SCENARIO"))
local max_frames = assert(tonumber(os.getenv("PACMAN_RUNTIME_MAX_FRAMES")))
local output = assert(io.open(output_path, "w"))

local ANIMATION = 0x0032
local SCRIPT = 0x003F
local PLAYER = 0x0046
local GAME_MODE = 0x0047
local PAUSE = 0x004A
local BUTTONS = 0x004D
local LIVES_P1 = 0x0067
local STAGE_P1 = 0x0068
local LIVES_P2 = 0x0077
local SHARED = 0x0087
local GHOST_STATE = 0x00B8
local PHASE = 0x00D0
local DEATH_TIMER = 0x00DB
local CHANNEL_INDEX = 0x00FC
local CHANNEL_OFFSET = 0x00FD
local PAUSE_SFX = 0x060F
local CHANNELS = 0x0625
local FRAME_COUNTER = 0x004B
local heartbeat_interval = tonumber(os.getenv("PACMAN_RUNTIME_HEARTBEAT_INTERVAL") or "0")
local probe_addresses_path = os.getenv("PACMAN_RUNTIME_PROBE_ADDRESSES")

local function symbol(name)
    local address = debugger.getsymboloffset(name)
    assert(address ~= nil and address >= 0, "missing debugger symbol: " .. name)
    return address
end

local function byte(address) return memory.readbyte(address) end
local function hex(address) return string.format("%02X", byte(address)) end
local function ghost_states()
    return hex(GHOST_STATE) .. hex(GHOST_STATE + 2) .. hex(GHOST_STATE + 4) .. hex(GHOST_STATE + 6)
end

local function emit(event, detail)
    output:write(string.format(
        "%d,%s,%s,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%s,%02X,%02X\n",
        emu.framecount(), event, detail or "", byte(SCRIPT), byte(PLAYER),
        byte(LIVES_P1), byte(LIVES_P2), byte(STAGE_P1), byte(SHARED),
        byte(SHARED + 1), ghost_states(), byte(PHASE), byte(PAUSE)))
    output:flush()
end

local function patch(address, value, reason)
    local previous = byte(address)
    if previous ~= value then
        memory.writebyte(address, value)
    end
    emit("controlled_patch", string.format("%04X:%02X>%02X:%s", address, previous, value, reason))
end

output:write("frame,event,detail,script,player,lives_p1,lives_p2,stage,scene,substate,ghost_states,phase,pause\n")
emit("trace_start", scenario)

if probe_addresses_path ~= nil and probe_addresses_path ~= "" then
    local function register_probe(address)
        memory.registerexecute(address, function()
            emit("relocation_probe_executed", string.format("%04X", address))
        end)
    end
    for line in io.lines(probe_addresses_path) do
        local address = assert(tonumber(line, 16), "invalid relocation probe address")
        register_probe(address)
    end
end

memory.registerexecute(symbol("sub_queue_next_ghost_release"), function()
    emit("release_requested", "sub_queue_next_ghost_release")
end)
memory.registerexecute(symbol("sub_try_reverse_ghost_directions"), function()
    emit("ghost_reversal", "sub_try_reverse_ghost_directions")
end)

local seen_sound = {}
memory.registerexecute(symbol("loc_decode_sound_stream_byte"), function()
    local channel = byte(CHANNEL_INDEX)
    local offset = byte(CHANNEL_OFFSET)
    local cursor = byte(CHANNELS + offset + 5) + byte(CHANNELS + offset + 6) * 256
    local value = byte(cursor)
    local class = value < 0xC0 and "note" or (value < 0xF0 and "duration" or "control")
    local key = string.format("%02X:%02X", channel, value)
    if not seen_sound[key] then
        seen_sound[key] = true
        emit("sound_" .. class, string.format("ch%02X:%02X", channel, value))
    end
end)

local pause_phase = 0
memory.registerexecute(symbol("handler_script04_pause_handler"), function()
    if scenario ~= "pause-resume" or emu.framecount() < 22000 then return end
    if pause_phase == 0 then
        patch(BUTTONS, bit.bor(byte(BUTTONS), 0x08), "pause_press")
        pause_phase = 1
    elseif pause_phase == 1 then
        if byte(PAUSE) % 2 == 1 and byte(PAUSE_SFX) == 0 then pause_phase = 3 end
    elseif pause_phase == 3 then
        patch(BUTTONS, bit.bor(byte(BUTTONS), 0x08), "resume_press")
        pause_phase = 4
    end
end)

local intermission_patched = false
memory.registerexecute(symbol("handler_script_0c_stage_clear"), function()
    if intermission_patched or emu.framecount() < 20000 then return end
    if scenario == "intermission-scene-1" then
        patch(STAGE_P1, 0x04, "select_scene_1")
        intermission_patched = true
    elseif scenario == "intermission-scene-2" then
        patch(STAGE_P1, 0x08, "select_scene_2")
        intermission_patched = true
    end
end)

local death_patched = false
local previous = {
    script = byte(SCRIPT), player = byte(PLAYER), lives1 = byte(LIVES_P1),
    lives2 = byte(LIVES_P2), stage = byte(STAGE_P1), scene = byte(SHARED),
    substate = byte(SHARED + 1), ghosts = ghost_states(), phase = byte(PHASE),
    pause = byte(PAUSE)
}

while emu.framecount() < max_frames do
    emu.frameadvance()

    if heartbeat_interval > 0 and emu.framecount() % heartbeat_interval == 0 then
        emit("heartbeat", string.format("frame_counter=%02X", byte(FRAME_COUNTER)))
    end

    if scenario == "death-player-switch" and not death_patched
        and emu.framecount() >= 22000 and byte(SCRIPT) == 0x04 then
        patch(SCRIPT, 0x08, "enter_death_script")
        patch(ANIMATION, 0x1D, "terminal_death_animation")
        patch(GAME_MODE, 0x01, "two_player_handoff")
        patch(SHARED, 0x01, "death_animation_phase")
        patch(DEATH_TIMER, 0x00, "terminal_step_due")
        death_patched = true
    end

    local current = {
        script = byte(SCRIPT), player = byte(PLAYER), lives1 = byte(LIVES_P1),
        lives2 = byte(LIVES_P2), stage = byte(STAGE_P1), scene = byte(SHARED),
        substate = byte(SHARED + 1), ghosts = ghost_states(), phase = byte(PHASE),
        pause = byte(PAUSE)
    }
    if current.script ~= previous.script then emit("script_changed", string.format("%02X>%02X", previous.script, current.script)) end
    if current.player ~= previous.player then emit("player_changed", string.format("%02X>%02X", previous.player, current.player)) end
    if current.lives1 ~= previous.lives1 then emit("lives_p1_changed", string.format("%02X>%02X", previous.lives1, current.lives1)) end
    if current.lives2 ~= previous.lives2 then emit("lives_p2_changed", string.format("%02X>%02X", previous.lives2, current.lives2)) end
    if current.stage ~= previous.stage then emit("stage_changed", string.format("%02X>%02X", previous.stage, current.stage)) end
    if current.ghosts ~= previous.ghosts then emit("ghost_states_changed", previous.ghosts .. ">" .. current.ghosts) end
    if current.phase ~= previous.phase then emit("mode_phase_changed", string.format("%02X>%02X", previous.phase, current.phase)) end
    if current.pause ~= previous.pause then emit("pause_changed", string.format("%02X>%02X", previous.pause, current.pause)) end
    if current.script == 0x10 and (current.scene ~= previous.scene or current.substate ~= previous.substate) then
        emit("intermission_state_changed", string.format("%02X:%02X>%02X:%02X", previous.scene, previous.substate, current.scene, current.substate))
    end
    previous = current
end

emit("trace_end", scenario)
output:close()
emu.exit()
