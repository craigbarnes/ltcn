LUA ?= lua
RM  ?= rm -f

check:
	@$(LUA) test/compare.lua test/t1.ltcn
	@$(LUA) test/compare.lua test/numbers.ltcn
	@$(LUA) test/errors.lua
	@echo OK

check-all:
	make -s check LUA=lua5.3
	make -s check LUA=lua5.2
	make -s check LUA=lua5.1
	make -s check LUA=luajit

ltcn-%-1.rockspec: rockspec.in
	@sed 's/%VERSION%/$*/' $< > $@
	@LUA_PATH=';;' luarocks lint $@
	@echo 'Generated: $@'

clean:
	$(RM) ltcn-*.rockspec


.PHONY: check check-all clean
.DELETE_ON_ERROR:
