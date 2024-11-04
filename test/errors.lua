local ltcn = require "ltcn"
local parse = ltcn.parse
local pcall, type, assert, error = pcall, type, assert, error
local _ENV = nil

local function assertError(input, line, column, pattern)
    local t, e = parse(input)
    assert(t == nil)
    assert(type(e) == "string")
    if e:find(("^:%d:%d:"):format(line, column)) == nil then
        local message = 'Expected error at %d:%d, got error:\n   "%s"'
        error(message:format(line, column, e), 2)
    end
    if pattern and not e:match(pattern) then
        local message = 'Expected error to match "%s", got error:\n   "%s"'
        error(message:format(pattern, e), 2)
    end
end

local function assertArgError(arg1, arg2, expected_err)
    local t, e = pcall(parse, arg1, arg2)
    assert(t == false)
    assert(type(e) == "string")
    if e ~= expected_err then
        local message = 'Expected error to be "%s", got error:\n   "%s"'
        error(message:format(expected_err, e), 2)
    end
end

assertError("  {1, 2, 3, true, false, -0, 'etc'}   x  ", 1, 39)
assertError(" --[[\n cmt1 \n]]\n-- cmt2\n-- cmt3\n\n  oops \n {}", 7, 3)
assertError("{ [{'x', 'y', 'z'}] = 'xyz' }", 1, 4)
assertError("{a = true, locals = true, do = false}", 1, 27)
assertError("{key = 'Hello\nWorld!'}", 2, 0, "unexpected '\\n', expecting \"'\"$")
assertError("{key = 'Hello\rWorld!'}", 1, 14)
assertError("", 1, 1, "unexpected 'EOF', expecting '{'$")
assertError(" \n --[=[ --]]\n --]=] {   \n\n", 5, 0)
assertError("{x = .}", 1, 6)
assertError("{x = .e+2}", 1, 6, "unexpected '.', expecting '{', Boolean, Number, String$")
assertError("{x = 918273645.f}", 1, 16)
assertError("{x = 009520000.000.222}", 1, 19)
assertError('{x = "\\j"}', 1, 8, "unexpected 'j', expecting CharEscape, DecimalEscape$")
assertError('{x = "\\"}', 1, 9)
assertError('{"\\256"}', 1, 4)
assertError('{"\\290"}', 1, 4)
assertError('{"\\301"}', 1, 4)
assertError('{"\\900"}', 1, 4)
assertError('{"\\999"}', 1, 4, "unexpected '999', expecting CharEscape, DecimalEscape$")
assertError('{42"s"}', 1, 4, "unexpected '\"s\"', expecting ',', ';', '}'$")

-- Unsupported Lua 5.2+ features
assertError('{x = 0x1.5p-3}', 1, 9)
assertError('{x = 0x0.1E}', 1, 9)
assertError('{x = 0xA23p-4}', 1, 11)
assertError('{x = 0X1.921FB54442D18P+1}', 1, 9)
assertError('{x = "\\xFF"}', 1, 8)
assertError('{x = "\\z\n  x"}', 1, 8)
assertError('{x = "\\u{1F311}"}', 1, 8)

assertArgError({}, nil, "bad argument #1: string expected, got table")
assertArgError(0, nil, "bad argument #1: string expected, got number")
assertArgError("", false, "bad argument #2: string expected, got boolean")
assertArgError("", 55, "bad argument #2: string expected, got number")
assertArgError("", {"..."}, "bad argument #2: string expected, got table")
