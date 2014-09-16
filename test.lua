local ltcn = require "ltcn"
local serpent = require "serpent"

local input = [=[
{
    1, -2, 3, -0xff, -0, true, false, 'hi', "hello",
    {'a','b','c'}, field1 = 55, ["field2"] = 44.0e-3, [false] = false,
    ["\a\b\n\\'\""] = '"\n\t\r\\\r\n'
}
]=]

local t, err = ltcn.parse(input, "")

if not t then
    io.stderr:write(err, "\n")
    os.exit(1)
else
    print(serpent.block(t, {comment = false}))
end
