local ltcn = require "ltcn"
local serpent = require "serpent"

local t, err = ltcn.parse_file "test/t1.ltcn"

if not t then
    io.stderr:write(err, "\n")
    os.exit(1)
else
    print(serpent.block(t, {comment = false}))
end
