-- Runtime proof that the expanded maze is addressed through the new PRG bank.

local output_path = assert(os.getenv("PACMAN_EXPANDED_RUNTIME_RESULT"))
local output = assert(io.open(output_path, "w"))
local stage_ready = debugger.getsymboloffset("bra_after_stage_increment_check")
local maze = debugger.getsymboloffset("tbl_expanded_maze_rle_stream")
local pointer = debugger.getsymboloffset("tbl_maze_rle_stream_ptr")

if stage_ready == nil or maze == nil or pointer == nil then
    output:write("FAIL,missing_symbol\n")
    output:close()
    emu.exit()
    return
end

local reached = false
memory.registerexecute(stage_ready, function() reached = true end)
for _ = 1, 10000 do
    if reached then break end
    emu.frameadvance()
end

local target = memory.readbyte(pointer) + memory.readbyte(pointer + 1) * 256
if not reached then
    output:write("FAIL,stage_init_not_reached\n")
else
    output:write(string.format(
        "maze,%04X,%04X,%02X\nOK\n", maze, target, memory.readbyte(target)))
end
output:close()
emu.exit()
