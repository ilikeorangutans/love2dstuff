luaunit = require('luaunit')

pretty = require('pl.pretty')
require('bus')

TestBus = {}

function TestBus:setUp()
  self.bus = Bus:new()
end

function TestBus:testSubscribeAndFire()
  local event = nil
  self.bus:subscribe("test", nil, function(receiver, e) event = e end)

  local expected = { foo="bar" }
  self.bus:fire("test", expected)

  luaunit.assertEquals(event, expected)
end

function TestBus:testUnsubscribe()
  local f = function(receiver, e) event = e end
  local f2 = function(receiver, e) event = e end
  self.bus:subscribe("test", nil, f)
  self.bus:subscribe("test", nil, f2)

  self.bus:unsubscribe("test", nil, f)

  luaunit.assertEquals(#(self.bus.subscriptions['test']), 1)
end

os.exit(luaunit.LuaUnit.run())
