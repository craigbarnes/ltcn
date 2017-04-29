local ltcn = require "ltcn"
local parse = ltcn.parse
local pcall, type, assert, error = pcall, type, assert, error
local _ENV = nil

local function assertError(input, line, column)
    local t, e = parse(input)
    assert(t == nil)
    assert(type(e) == "string")
    if e:find(("^:%d:%d:"):format(line, column)) == nil then
        local message = 'Expected error at %d:%d, got error:\n   "%s"'
        error(message:format(line, column, e), 2)
    end
end

local function assertArgError(arg1, arg2)
    local t, e = pcall(parse, arg1, arg2)
    assert(t == false)
    assert(type(e) == "string")
end

assertError("  {1, 2, 3, true, false, -0, 'etc'}   x  ", 1, 39)
assertError(" --[[\n cmt1 \n]]\n-- cmt2\n-- cmt3\n\n  oops \n {}", 7, 3)
assertError("{ [{'x', 'y', 'z'}] = 'xyz' }", 1, 4)
assertError("{a = true, locals = true, do = false}", 1, 27)
assertError("{key = 'Hello\nWorld!'}", 2, 0)
assertError("{key = 'Hello\rWorld!'}", 1, 14)
assertError("", 1, 1)
assertError(" \n --[=[ --]]\n --]=] {   \n\n", 5, 0)
assertError("{x = .}", 1, 6)
assertError("{x = .e+2}", 1, 6)
assertError("{x = 918273645.f}", 1, 16)
assertError("{x = 009520000.000.222}", 1, 19)
assertError('{x = "\\j"}', 1, 8)
assertError('{x = "\\"}', 1, 9)
-- TODO: assertError('{xyz = "\256"}', 1, 9)

-- Unsupported Lua 5.2+ features
assertError('{x = 0x1.5p-3}', 1, 9)
assertError('{x = "\\xFF"}', 1, 8)
assertError('{x = "\\z\n  x"}', 1, 8)
assertError('{x = "\\u{1F311}"}', 1, 8)

assertArgError({})
assertArgError(0)
assertArgError("", false)
assertArgError("", 55)
assertArgError("", {"..."})
