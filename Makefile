LUA ?= lua
LUAROCKS ?= luarocks
RM  ?= rm -f

check:
	@$(LUA) test/compare.lua test/t1.ltcn
	@$(LUA) test/compare.lua test/nesting.ltcn
	@$(LUA) test/compare.lua test/numbers.ltcn
	@$(LUA) test/errors.lua
	@echo OK

check-all:
	$(MAKE) -s check LUA=lua5.3
	$(MAKE) -s check LUA=lua5.2
	$(MAKE) -s check LUA=lua5.1
	$(MAKE) -s check LUA=luajit

check-luarocks-build check-luarocks-make: \
check-luarocks-%: | ltcn-scm-1.rockspec
	$(LUAROCKS) --tree='$(CURDIR)/build/$@' $* $|
	$(RM) -r build/$@/

ltcn-scm-1.rockspec: private URL = git+https://github.com/craigbarnes/ltcn.git
ltcn-scm-1.rockspec: private SRCX = branch = "master"
ltcn-scm-1.rockspec: rockspec.in
	@sed 's|%VERSION%|scm|;s|%URL%|$(URL)|;s|%SRCX%|$(SRCX)|' $< > $@
	@$(LUAROCKS) lint $@
	@echo 'Generated: $@'

clean:
	$(RM) ltcn-*.rockspec


.PHONY: check check-all check-luarocks-build check-luarocks-make clean
.DELETE_ON_ERROR:
