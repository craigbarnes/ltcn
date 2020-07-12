LUA ?= lua
LUAROCKS ?= luarocks
RM = rm -f

check:
	$(LUA) test/compare.lua test/t1.ltcn
	$(LUA) test/compare.lua test/nesting.ltcn
	$(LUA) test/compare.lua test/numbers.ltcn
	$(LUA) test/errors.lua
	@echo OK

check-all: MAKEFLAGS += --no-print-directory
check-all:
	$(MAKE) check LUA=lua5.3
	$(MAKE) check LUA=lua5.2
	$(MAKE) check LUA=lua5.1
	$(MAKE) check LUA=luajit

check-luarocks-build check-luarocks-make: check-luarocks-%:
	$(LUAROCKS) --tree='$(CURDIR)/build/$@' $* ltcn-scm-1.rockspec
	$(RM) -r build/$@/


.PHONY: check check-all check-luarocks-build check-luarocks-make
.DELETE_ON_ERROR:
