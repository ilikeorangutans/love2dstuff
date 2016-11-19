luaunit = require('luaunit')
require('bus')

TestBus = {}

function TestBus:setUp()
  self.bus = Bus:new()
end

function TestBus:testSubscribe()
end

os.exit(luaunit.LuaUnit.run())
