LUA ?= lua
RM  ?= rm -f

check: test/compare.lua test/t1.ltcn test/errors.lua
	@$(LUA) test/compare.lua test/t1.ltcn
	@$(LUA) test/errors.lua
	@echo OK

ltcn-%-1.rockspec: rockspec.in | .git/refs/tags/%
	@sed 's/%VERSION%/$*/' $< > $@
	@LUA_PATH=';;' luarocks lint $@
	@echo 'Generated: $@'

clean:
	$(RM) ltcn-*.rockspec


.PHONY: check clean
.DELETE_ON_ERROR:
