local ltcn = require "ltcn"
local serpent = require "serpent"
local opts = {comment = false}

local t = assert(ltcn.parse_file(arg[1] or io.stdin))
io.write(serpent.block(t, opts), "\n")
