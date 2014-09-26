local ltcn = require "ltcn"

local t, e = ltcn.parse "  {1, 2, 3, true, false, -0, 'etc'}   x  "
assert(t == nil)
assert(e == ":1:39: Syntax error: unexpected 'x', expecting 'EOF'")
