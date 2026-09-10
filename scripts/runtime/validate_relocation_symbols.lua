-- Runtime proof that FCEUX follows the relocated semantic symbols.

local output_path = assert(os.getenv("PACMAN_DEBUG_SYMBOL_RESULT"))
local output = assert(io.open(output_path, "w"))

local names = {
    "vec_nmi_handler",
    "bra_dispatch_current_script",
    "sub_update_pacman_movement",
    "loc_add_points_and_update_score_buffers",
    "sub_update_ghost_slots",
    "sub_write_buffer_to_ppu",
    "sub_update_sound_engine",
    "ram_script",
}

local addresses = {}
for _, name in ipairs(names) do
    local address = debugger.getsymboloffset(name)
    if address == nil or address < 0 then
        output:write("FAIL,symbol_lookup\n")
        output:close()
        emu.exit()
        return
    end
    addresses[name] = address
    output:write(string.format("symbol,%s,%04X,%04X\n", name, address, address))
end

local nmi_hit = false
memory.registerexecute(addresses.vec_nmi_handler, function()
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
    output:write(string.format(
        "break,vec_nmi_handler,%04X,%d\n",
        addresses.vec_nmi_handler,
        emu.framecount()))
    output:write("OK\n")
end
output:close()
emu.exit()
