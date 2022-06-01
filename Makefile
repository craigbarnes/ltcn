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
	$(MAKE) check LUA=lua5.4
	$(MAKE) check LUA=lua5.3
	$(MAKE) check LUA=lua5.2
	$(MAKE) check LUA=lua5.1

check-luarocks: ltcn-scm-1.rockspec | build/
	$(LUAROCKS) lint $<
	$(LUAROCKS) --tree='$(CURDIR)/build/scm-1-rock' make $<

build/:
	mkdir -p $@

clean:
	$(RM) -r build/


.PHONY: check check-all check-luarocks clean
.DELETE_ON_ERROR:
