local ltcn = require "ltcn"
local parse = ltcn.parse

do
    local t, e = parse "  {1, 2, 3, true, false, -0, 'etc'}   x  "
    assert(t == nil)
    assert(e == ":1:39: Syntax error: unexpected 'x', expecting 'EOF'")
end

do
    local t, e = parse " --[[\n cmt1 \n]]\n-- cmt2\n-- cmt3\n\n  oops \n {}"
    assert(t == nil)
    assert(e == ":7:3: Syntax error: unexpected 'oops', expecting '{'")
end

do
    local t, e = parse "{ [{'x', 'y', 'z'}] = 'xyz' }"
    assert(t == nil)
    assert(e == ":1:4: Syntax error: unexpected '{', expecting 'Boolean', 'String', 'Number'")
end

do
    local t, e = parse "{a = true, locals = true, do = false}"
    assert(t == nil)
    assert(e == ":1:27: Syntax error: unexpected 'do', expecting '}', '{', 'Boolean', 'String', 'Number', 'Name', '['")
end

do
    local t, e = parse "{key = 'Hello\nWorld!'}"
    assert(t == nil)
    assert(e == ":2:0: Syntax error: unexpected '\\n', expecting '''")
end

do
    local t, e = parse "{key = 'Hello\rWorld!'}"
    assert(t == nil)
    assert(e == ":1:14: Syntax error: unexpected '\\r', expecting '''")
end

do
    local t, e = parse ""
    assert(t == nil)
    assert(e == ":1:1: Syntax error: unexpected 'EOF', expecting '{'")
end

do
    local t, e = parse " \n --[=[ --]]\n --]=] {   \n\n"
    assert(t == nil)
    assert(e == ":5:0: Syntax error: unexpected 'EOF', expecting '}', '{', 'Boolean', 'String', 'Number', 'Name', '['")
end
