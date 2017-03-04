TESTS=$(wildcard test/*_test.lua)

run:
	love .

lint:
	luacheck .

.PHONY: test clean
test: $(addsuffix .run, $(TESTS))

test/%.lua.run: test/%.lua
	lua $< -o tap

build_dirs:
	mkdir -p build
	mkdir -p dist
	mkdir -p dist/deps

dist: build_dirs dist/love.zip dist/dist.love macosx

macosx: macosxdeps dist/ancol.app Info.plist
	cp -v dist/dist.love dist/ancol.app/Contents/Resources
	cp -v Info.plist dist/ancol.app/Contents

macosxdeps:
	mkdir -p dist/deps/macosx
	luarocks --tree dist/deps/macosx install luabitop

dist/love.zip:
	curl -J -L https://bitbucket.org/rude/love/downloads/love-0.10.2-macosx-x64.zip -o dist/love.zip

dist/dist.love:
	cp *.lua build
	cp -r ui build
	cp -r view build
	cp -r assets build
	cd build && zip -9 -r ../dist/dist.love . ; cd ..

dist/ancol.app:
	pushd . && cd dist && unzip -o love.zip && popd
	mv dist/love.app dist/ancol.app

clean:
	rm -rf build
	rm -rf dist

install_deps:
	luarocks install --local luaunit
	luarocks install --local luabitop
