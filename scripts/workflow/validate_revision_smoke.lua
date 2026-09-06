-- Capture title-menu and shadow-OAM facts for one official revision build.

local output_path = assert(os.getenv("PACMAN_REVISION_SMOKE_RESULT"))
local max_frames = assert(tonumber(os.getenv("PACMAN_REVISION_SMOKE_MAX_FRAMES")))
local output = assert(io.open(output_path, "w"))

local OAM = 0x0700
local nmi_hits = 0
local menu_hit = false
local oam_value = -1
local oam_uniform = false
local first_difference = -1

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
    oam_value = memory.readbyte(OAM)
    oam_uniform = true
    for offset = 1, 255 do
        if memory.readbyte(OAM + offset) ~= oam_value then
            oam_uniform = false
            if first_difference < 0 then first_difference = offset end
        end
    end
end)

while emu.framecount() < max_frames and not menu_hit do
    emu.frameadvance()
end

output:write(string.format("frames=%d\n", emu.framecount()))
output:write(string.format("nmi_hits=%d\n", nmi_hits))
output:write(string.format("menu_hit=%s\n", tostring(menu_hit)))
output:write(string.format("oam_value=%d\n", oam_value))
output:write(string.format("oam_uniform=%s\n", tostring(oam_uniform)))
output:write(string.format("oam_first_difference=%d\n", first_difference))
output:close()
emu.exit()
