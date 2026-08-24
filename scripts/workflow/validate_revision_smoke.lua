-- Boot an official regional build to its title menu and validate shadow OAM.

local output_path = assert(os.getenv("PACMAN_REVISION_SMOKE_RESULT"))
local max_frames = assert(tonumber(os.getenv("PACMAN_REVISION_SMOKE_MAX_FRAMES")))
local expected_oam_fill = assert(tonumber(os.getenv("PACMAN_REVISION_SMOKE_OAM_FILL")))
local output = assert(io.open(output_path, "w"))

local OAM = 0x0700
local nmi_hits = 0
local menu_hit = false
local mismatch_count = 0
local first_mismatch = -1

local function symbol(name)
    local address = debugger.getsymboloffset(name)
    assert(address ~= nil and address >= 0, "missing debugger symbol: " .. name)
    return address
end

memory.registerexecute(symbol("vec_nmi_handler"), function()
    nmi_hits = nmi_hits + 1
end)

memory.registerexecute(symbol("handler_script02_title_menu_idle"), function()
    if menu_hit then return end
    menu_hit = true
    for offset = 0, 255 do
        if memory.readbyte(OAM + offset) ~= expected_oam_fill then
            mismatch_count = mismatch_count + 1
            if first_mismatch < 0 then first_mismatch = offset end
        end
    end
end)

while emu.framecount() < max_frames and not menu_hit do
    emu.frameadvance()
end

output:write(string.format("frames=%d\n", emu.framecount()))
output:write(string.format("nmi_hits=%d\n", nmi_hits))
output:write(string.format("menu_hit=%s\n", tostring(menu_hit)))
output:write(string.format("oam_expected=%02X\n", expected_oam_fill))
output:write(string.format("oam_mismatches=%d\n", mismatch_count))
output:write(string.format("oam_first_mismatch=%d\n", first_mismatch))
if menu_hit and nmi_hits > 0 and mismatch_count == 0 then
    output:write("status=PASS\n")
else
    output:write("status=FAIL\n")
end
output:close()
emu.exit()
