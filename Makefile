
run:
	love .

lint:
	luacheck .

.PHONY: test clean
test:
	lua test/*_test.lua

dist: dist.love

dist.love:
	mkdir -p build
	mkdir -p dist
	cp *.lua build
	cp -r assets build
	cd build && zip -9 -r ../dist/dist.love . ; cd ..

clean:
	rm -rf build
	rm -rf dist


install_deps:
	luarocks install --local luaunit
	luarocks install --local luabitop
