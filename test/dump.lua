local ltcn = require "ltcn"
local serpent = require "serpent"
local opts = {comment = false}

local t, err = ltcn.parse_file(arg[1] or io.stdin)

if t then
    io.write(serpent.block(t, opts), "\n")
else
    io.stderr:write(err, "\n")
    os.exit(1)
end
