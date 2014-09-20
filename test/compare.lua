local ltcn = require "ltcn"
local verbose = os.getenv "VERBOSE"

local function printf(...)
    io.stderr:write(string.format(...))
end

local function compare(t1, t2)
    for k, v1 in pairs(t1) do
        local v2 = t2[k]
        if type(v1) == "table" then
            assert(type(v2) == "table", "Not a table")
            compare(v1, v2)
        elseif v1 ~= v2 then
            printf("Error: values not equal: (%s, %s)\n", v1, v2)
            os.exit(1)
        elseif verbose then
            printf("OK:  %-15s %s\n", v1, v2)
        end
    end
    return true
end

local filename = assert(arg[1], "arg[1] is nil; expected filename")
local file = assert(io.open(filename))
local text = assert(file:read("*a"))

local t1 = assert(ltcn.parse(text, filename))
local fn = assert(load("return" .. text, "="..filename, "t"))
local t2 = assert(fn())

compare(t1, t2)
compare(t2, t1)
