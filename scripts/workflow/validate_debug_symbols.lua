-- Runtime proof that FCEUX loaded generated semantic symbols and can break on one.

local output_path = assert(os.getenv("PACMAN_DEBUG_SYMBOL_RESULT"))
local output = assert(io.open(output_path, "w"))

local expected = {
    vec_nmi_handler = 0xC0FA,
    bra_dispatch_current_script = 0xC9FE,
    sub_update_pacman_movement = 0xD2FB,
    loc_add_points_and_update_score_buffers = 0xE060,
    sub_update_ghost_slots = 0xD4C2,
    sub_write_buffer_to_ppu = 0xDDE9,
    sub_update_sound_engine = 0xEE5C,
    ram_script = 0x003F,
}

for symbol, expected_address in pairs(expected) do
    local actual_address = debugger.getsymboloffset(symbol)
    output:write(string.format(
        "symbol,%s,%04X,%04X\n", symbol, actual_address, expected_address))
    if actual_address ~= expected_address then
        output:write("FAIL,symbol_lookup\n")
        output:close()
        emu.exit()
        return
    end
end

local nmi_address = debugger.getsymboloffset("vec_nmi_handler")
local nmi_hit = false
memory.registerexecute(nmi_address, function()
    nmi_hit = true
end)

for _ = 1, 120 do
    if nmi_hit then
        break
    end
    emu.frameadvance()
end

if not nmi_hit then
    output:write("FAIL,semantic_breakpoint\n")
else
    output:write(string.format("break,vec_nmi_handler,%04X,%d\n", nmi_address, emu.framecount()))
    output:write("OK\n")
end
output:close()
emu.exit()
