-- Runtime proof that stage 2 selects its own maze in the expanded PRG bank.

local output_path = assert(os.getenv("PACMAN_EXPANDED_RUNTIME_RESULT"))
local output = assert(io.open(output_path, "w"))
local round_init = debugger.getsymboloffset("handler_script00_round_init")
local stage_ready = debugger.getsymboloffset("bra_init_ghost_release_state")
local maze = debugger.getsymboloffset("tbl_expanded_stage2_maze_rle_stream")
local stage = debugger.getsymboloffset("tbl_expanded_stage_parameters")
local maze_row = debugger.getsymboloffset("bra_upload_next_maze_row")
local stage_number = debugger.getsymboloffset("ram_stage_p1")
local frightened_duration = debugger.getsymboloffset("ram_frightened_duration")
local sound_table_pointer = debugger.getsymboloffset("tbl_sfx_stream_table_ptr")
local sound_requests = debugger.getsymboloffset("ram_sfx")
local sound_channels = debugger.getsymboloffset("ram_sound_channel_state")
local demo_flag = debugger.getsymboloffset("ram_flag_demo")

if round_init == nil or stage_ready == nil or maze == nil or stage == nil or maze_row == nil
        or stage_number == nil or frightened_duration == nil or sound_table_pointer == nil
        or sound_requests == nil or sound_channels == nil or demo_flag == nil then
    output:write("FAIL,missing_symbol\n")
    output:close()
    emu.exit()
    return
end

local active_sound_table = memory.readbyte(sound_table_pointer)
    + memory.readbyte(sound_table_pointer + 1) * 256
local pellet_pointer_entry = active_sound_table + 4 * 2
local pellet_stream = memory.readbyte(pellet_pointer_entry)
    + memory.readbyte(pellet_pointer_entry + 1) * 256

local forced = false
local reached = false
local selected_maze = nil
memory.registerexecute(round_init, function()
    if not forced then
        -- Round init increments this value before selecting stage data.
        memory.writebyte(stage_number, 0)
        forced = true
    end
end)
memory.registerexecute(maze_row, function()
    if selected_maze == nil then
        selected_maze = memory.readbyte(0) + memory.readbyte(1) * 256
    end
end)
memory.registerexecute(stage_ready, function() reached = true end)
for _ = 1, 10000 do
    if reached then break end
    emu.frameadvance()
end

memory.writebyte(demo_flag, 0)
memory.writebyte(sound_requests + 4, 1)
for _ = 1, 60 do emu.frameadvance() end
local pellet_cursor_address = sound_channels + 4 * 8 + 5
local pellet_cursor = memory.readbyte(pellet_cursor_address)
    + memory.readbyte(pellet_cursor_address + 1) * 256

if not reached or selected_maze == nil then
    output:write("FAIL,stage_init_not_reached\n")
else
    output:write(string.format(
        "maze,%04X,%04X,%02X\nstage,%04X,%02X,%02X\n"
            .. "sound,%04X,%04X,%04X,%02X\nOK\n",
        maze, selected_maze, memory.readbyte(selected_maze), stage,
        memory.readbyte(stage + 7), memory.readbyte(frightened_duration),
        active_sound_table, pellet_stream, pellet_cursor, memory.readbyte(pellet_stream + 4)))
end
output:close()
emu.exit()
