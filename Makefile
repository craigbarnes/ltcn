check: test/compare.lua test/t1.ltcn
	@lua test/compare.lua test/t1.ltcn
	@echo OK

ltcn-%-1.rockspec: rockspec.in | .git/refs/tags/%
	@sed 's/%VERSION%/$*/' $< > $@
	@LUA_PATH=';;' luarocks lint $@
	@echo 'Generated: $@'

clean:
	$(RM) ltcn-*.rockspec


.PHONY: check clean
.DELETE_ON_ERROR:
