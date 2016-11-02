LTCN
====

LTCN or "Lua Table Constructor Notation" aims to be to Lua, as JSON is
to JavaScript, with the exception of also supporting comments and
unquoted keys.

Goals and features:

* Support parsing any valid Lua table constructor that consists of string,
  number or boolean *keys* and string, number, boolean or table *values*.
* Allow comments and whitespace in the same positions as Lua does.
* In the absence of errors, produce the same table structure as Lua's [`load`]
  function (in text mode), given the same input.
* Ignore a single `return` keyword before the outermost opening brace, as a
  convenience for the above.
* Provide the same security advantages as `JSON.parse` does, as compared to
  `eval`, for parsing input from untrusted sources or networks.

Non-goals:

* Allowing tables as keys. This was supported at one point, but every
  use case I could think of would have required additional features
  (that clash with other goals) in order to be useful.
* Support for structures that require more than simple table constructors
  to initialize (e.g. those with self references, shared references etc.).
* Expression evaluation. Constant expressions can be normalized to simple
  values. Non-constant expressions are beyond the scope of LTCN.
* Support for metatables, functions, conditionals etc. This format is known
  as "Lua" and is already handled well by the [`load`] function
  (although this obviously requires much greater caution if handling
  untrusted input).

Requirements
------------

* [Lua] >= 5.1 or [LuaJIT] >= 2.0
* [LPeg] >= 0.12

[License]
---------

Copyright (c) 2014-2016 Craig Barnes.

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


[`load`]: http://www.lua.org/manual/5.2/manual.html#pdf-load
[License]: http://en.wikipedia.org/wiki/ISC_license "ISC License"
[Lua]: http://www.lua.org/
[LuaJIT]: http://luajit.org/
[LPeg]: http://www.inf.puc-rio.br/~roberto/lpeg/
