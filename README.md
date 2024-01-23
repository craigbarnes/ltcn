LTCN
====

LTCN or "Lua Table Constructor Notation" is a Lua library for parsing
and deserializing Lua table syntax via an [LPeg] grammar. It's intended
to parse a safe subset of the Lua language and to replace many common
use cases of the [`load`] function for reading data and configuration
files.

Features
--------

* Parses any Lua table constructor that consists of string, number or
  boolean *keys* and string, number, boolean or table *values*.
* Handles unescaping of escape sequences in string literals.
* Discards single-line comments and long comments.
* Permits a single `return` keyword before the outermost opening brace,
  to enable drop-in replacement of the [`load`] function.
* Provides useful error messages for syntax errors, including line and
  column numbers.

Requirements
------------

* [Lua] >= 5.1 or [LuaJIT] >= 2.0
* [LPeg] >= 0.12

Installation
------------

There's no versioned release yet, but for now the SCM [rock] can be
installed with:

    luarocks --server=https://luarocks.org/dev install ltcn

Features Not Implemented
------------------------

### Lua 5.2+ features

The following are features that were added to Lua after version 5.1 and
are deliberately not supported to simplify cross-version compatibility:

* Hexadecimal floating point literals (e.g. `0x1.5p-3`).
* Hexadecimal escape sequences in strings (e.g. `"\xFF"`)
* Whitespace escape sequences in strings (e.g. `"\z"`)
* Unicode escape sequences in strings (e.g. `"\u{1F311}"`)

### Beyond the scope of LTCN

The following are syntactical constructs of Lua that could theoretically
be supported, but are considered beyond the scope of the project:

* Tables as keys (not useful without considerable extra functionality).
* Tables that require more than a simple constructor to initialize
  (e.g. those with self references, shared references etc.).
* Expression evaluation.
* Metatables, functions, conditionals, etc. (just use the Lua
  [`load`] function for this).

License
-------

ISC [License][] (SPDX: [`ISC`]).


[`load`]: https://www.lua.org/manual/5.3/manual.html#pdf-load
[Lua]: https://www.lua.org/
[LuaJIT]: https://luajit.org/
[LPeg]: https://www.inf.puc-rio.br/~roberto/lpeg/
[rock]: https://luarocks.org/modules/craigb/ltcn
[License]: LICENSE
[`ISC`]: https://spdx.org/licenses/ISC.html
