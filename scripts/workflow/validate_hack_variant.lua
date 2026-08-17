-- Runtime proof for the default optional ROM-hack variant.

local output_path = assert(os.getenv("PACMAN_HACK_RUNTIME_RESULT"))
local output = assert(io.open(output_path, "w"))
local stage_address = debugger.getsymboloffset("ram_stage_p1")
local stage_ready = debugger.getsymboloffset("bra_after_stage_increment_check")

if stage_address == nil or stage_ready == nil then
    output:write("FAIL,missing_symbol\n")
    output:close()
    emu.exit()
    return
end

local observed = nil
memory.registerexecute(stage_ready, function()
    if observed == nil then
        observed = memory.readbyte(stage_address)
    end
end)

for _ = 1, 10000 do
    if observed ~= nil then break end
    emu.frameadvance()
end

if observed == nil then
    output:write("FAIL,stage_init_not_reached\n")
else
    output:write(string.format("stage,%d\nOK\n", observed))
end
output:close()
emu.exit()
