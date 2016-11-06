luaunit = require('luaunit')
require('map')

function testIteratorStuff()

  counter = 0
  it = function()
    counter = counter + 1
    if counter > 10 then
      return nil
    end
    return counter, 2 + counter, 3 + counter
  end

  for a, b, c in it do
    print(a, b, c)
  end
end

os.exit(luaunit.LuaUnit.run())
