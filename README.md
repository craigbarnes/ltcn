LTCN
====

LTCN or "Lua Table Constructor Notation" aims to be to Lua, as JSON is
to JavaScript, with the exception of also supporting comments and
unquoted keys.

Goals and features:

* Support parsing any valid Lua table constructor that consists of only
  string, number or boolean keys and string, number, boolean or table values.
* In the absence of errors, produce the same table structure as Lua's `load`
  function (in text mode).
* Ignore a single `return` keyword before the opening, outermost brace, as a
  convenience for the above.
* Provide the same security advantages as `JSON.parse` does compared to
  `eval`, for parsing input originating from untrusted sources or networks.

Non-goals:

* Support for tables as keys. This was supported at one point, but every
  use case I could think of would have required additional features
  (that clash with other goals) in order to be useful.
* Support for structures that require more than a single table
  constructor to initialize. [Serpent] is a better choice for this use case.
* Support for expression evaluation. Constant expressions can always be
  normalized to simple values. For non-constant expressions, Lua's
  `load` function is a better choice (although obviously not for
  untrusted input!).

Requirements
------------

* [Lua] 5.1+ or [LuaJIT] 2
* [LPeg] 0.12+

[License]
---------

Copyright (c) 2014 Craig Barnes.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


[License]: http://en.wikipedia.org/wiki/ISC_license "ISC License"
[Lua]: http://www.lua.org/
[LuaJIT]: http://luajit.org/
[LPeg]: http://www.inf.puc-rio.br/~roberto/lpeg/
