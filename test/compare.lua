local ltcn = require "ltcn"
local type, pairs, assert = type, pairs, assert
local open, stderr, exit = io.open, io.stderr, os.exit
local load = loadstring or load
local verbose = os.getenv "VERBOSE"
local filename = assert(arg[1], "arg[1] is nil; expected filename")
local _ENV = nil

local function compare(t1, t2)
    for k, v1 in pairs(t1) do
        local v2 = t2[k]
        if type(v1) == "table" then
            assert(type(v2) == "table", "Not a table")
            compare(v1, v2)
        elseif v1 ~= v2 then
            local s = ("(%s, %s)"):format(v1, v2)
            stderr:write(filename, ": Error: values not equal: ", s, "\n")
            exit(1)
        elseif verbose then
            stderr:write(("OK:  %-15s %s\n"):format(v1, v2))
        end
    end
    return true
end

local file = assert(open(filename))
local text = assert(file:read("*a"))

local t1 = assert(ltcn.parse(text, filename))
local fn = assert(load("return" .. text, "="..filename, "t"))
local t2 = assert(fn())

compare(t1, t2)
compare(t2, t1)
