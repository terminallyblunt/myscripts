#!/usr/bin/env lua

-- Random insult display script using ANSI colors
-- Converted from Bash to Lua

local INSULT_FILE = os.getenv("HOME") .. "/scripts/myinsults/insults.txt"

-- ANSI reset
local RESET = "\27[0m"

-- Muted border colors (256-color palette)
local BORDER_COLORS = {
    "\27[38;5;240m", -- Dark Grey
    "\27[38;5;244m", -- Medium Grey
    "\27[38;5;67m",  -- Steel Blue
    "\27[38;5;66m",  -- Muted Teal
    "\27[38;5;97m",  -- Muted Purple
    "\27[38;5;101m", -- Muted Olive
    "\27[38;5;109m", -- Dusty Blue
    "\27[38;5;138m", -- Muted Gold
}

-- Bright insult colors
local INSULT_COLORS = {
    "\27[91m",       -- Bright Red
    "\27[93m",       -- Bright Yellow
    "\27[95m",       -- Bright Magenta
    "\27[38;5;208m", -- Orange
    "\27[38;5;201m", -- Hot Pink
    "\27[38;5;82m",  -- Neon Green
    "\27[38;5;226m", -- Gold
    "\27[38;5;51m",  -- Electric Blue
    "\27[38;5;214m", -- Coral
}

-- Read file into table
local function read_lines(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end

    local lines = {}

    for line in file:lines() do
        -- FIX: do NOT reassign loop variable in Lua 5.4
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed ~= "" then
            lines[#lines + 1] = trimmed
        end
    end

    file:close()
    return lines
end

-- Load insults
local insults = read_lines(INSULT_FILE)

if not insults then
    io.stderr:write("\27[31mNo insults.txt found at " .. INSULT_FILE .. RESET .. "\n")
    os.exit(1)
end

if #insults == 0 then
    io.stderr:write("\27[31mNo insults found in " .. INSULT_FILE .. RESET .. "\n")
    os.exit(1)
end

-- Seed RNG
math.randomseed(os.time())

-- Pick random insult
local insult = insults[math.random(#insults)]
insult = " " .. insult

-- Pick random colors
local insult_color = INSULT_COLORS[math.random(#INSULT_COLORS)]
local border_color = BORDER_COLORS[math.random(#BORDER_COLORS)]

-- Build border line
local insult_len = #insult + 1
local border_line = string.rep("=", insult_len)

-- Output framed insult
print(border_color .. border_line .. RESET)
print(insult_color .. insult .. RESET)
print(border_color .. border_line .. RESET)
