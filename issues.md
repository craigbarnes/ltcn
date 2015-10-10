Issues
======

Don't accept newlines inside short strings
------------------------------------------

As per the title. The parser currently accepts newlines inside short
strings, whereas Lua reports an "unfinished string" error. This should
be fixed to follow the same behaviour as Lua -- preferably with the same
error message.

Allow nil values
----------------

`nil` is currently not allowed as a table key or value. Without
accepting `nil` as a value, occasionally useful constructs like `{1, 2,
nil, 4}` result in a parse error.

However, the fix isn't as simple as just adding `nil` as a valid value
in the grammar, since the `setfield` function uses `table.insert` and
will simply overwrite any index with a `nil` value on subsequent calls.
This can be fixed by keeping an index of table lengths, keyed by table
identity, and manually inserting each value and incrementing the length,
instead of using `table.insert`.

For now, this limitation is ok, since there are *many* edge cases that
must be handled by `setfield` if/when `nil` is an accepted value.

Support for luarocks style format
---------------------------------

There are 2 common ways of using Lua's `load()` function to read a table
of data from a file. The first is to capture the table returned by the
compiled chunk, for example:

```lua
return {
    key1 = true,
    key2 = "etc"
}
```

The second is to capture the environment table created as a side effect
of running the compiled chunk, for example:

```lua
key1 = true
key2 = "etc"
```

...as used in luarocks `.rockspec` files.

LTCN already supports the first method. This issue is to track the
addition of (a subset of) the second.

Others
------

* Add installation and usage information to readme
* Add enough test cases to cover every part of the grammar
