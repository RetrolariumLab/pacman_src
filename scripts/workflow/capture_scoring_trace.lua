-- Compact scoring-event trace for the instrumented FCEUX workflow.

local output_path = assert(os.getenv("PACMAN_SCORING_TRACE"))
local max_frames = assert(tonumber(os.getenv("PACMAN_SCORING_MAX_FRAMES")))
local output = assert(io.open(output_path, "w"))

local SCORE = 0x0070
local HISCORE = 0x0061
local LIVES = 0x0067
local EXTRA_LIFE_LATCH = 0x006B
local PELLETS = 0x006A
local FRIGHTENED_MASK = 0x0088
local FRUIT_LATCH = 0x008B
local KILL_COUNT = 0x00D9
local PENDING = 0x00DC

local function bytes(base, count)
    local values = {}
    for index = 0, count - 1 do
        values[#values + 1] = string.format("%02X", memory.readbyte(base + index))
    end
    return table.concat(values, "")
end

local function frame()
    return emu.framecount()
end

local function emit(event)
    output:write(string.format(
        "%d,%s,%s,%s,%s,%02X,%02X,%02X,%02X,%02X\n",
        frame(), event, bytes(PENDING, 6), bytes(SCORE, 6), bytes(HISCORE, 6),
        memory.readbyte(LIVES), memory.readbyte(EXTRA_LIFE_LATCH),
        memory.readbyte(PELLETS), memory.readbyte(FRIGHTENED_MASK),
        memory.readbyte(KILL_COUNT)))
    output:flush()
end

output:write("frame,event,pending_bcd,score_bcd,hiscore_bcd,lives,extra_life_latch,pellets,frightened_mask,kill_count\n")
output:flush()

memory.registerexecute(0xDEF7, function() emit("power_pellet") end)
memory.registerexecute(0xDF1E, function() emit("pellet") end)
memory.registerexecute(0xD26A, function() emit("actor_collision") end)
memory.registerexecute(0xD274, function() emit("ghost_award") end)
memory.registerexecute(0xD2B8, function() emit("fruit_award") end)
memory.registerexecute(0xE060, function() emit("score_commit") end)

local previous_score = bytes(SCORE, 6)
local previous_hiscore = bytes(HISCORE, 6)
local previous_lives = memory.readbyte(LIVES)
local previous_latch = memory.readbyte(EXTRA_LIFE_LATCH)

while frame() < max_frames do
    emu.frameadvance()

    local score = bytes(SCORE, 6)
    local hiscore = bytes(HISCORE, 6)
    local lives = memory.readbyte(LIVES)
    local latch = memory.readbyte(EXTRA_LIFE_LATCH)

    if score ~= previous_score then emit("score_changed") end
    if hiscore ~= previous_hiscore then emit("hiscore_changed") end
    if lives ~= previous_lives then emit("lives_changed") end
    if previous_latch == 0 and latch == 1 then emit("extra_life_awarded") end

    previous_score = score
    previous_hiscore = hiscore
    previous_lives = lives
    previous_latch = latch
end

output:close()
emu.exit()
