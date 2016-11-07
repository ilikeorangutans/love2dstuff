luaunit = require('luaunit')
require('util')
require('terrain')
require('map')

TestMapView = {}

function TestMapView:setUp()
  local map = Map:new()
  map:fromString(4, 4, "1111122112211111")
  self.map = map

  local mapView = MapView:new({map=map})
  self.mapView = mapView
end

function TestMapView:testIsExplored()
  luaunit.assertFalse(self.mapView:isExplored(posAt(0, 0)))
  self.mapView:setExplored(posAt(0, 0))
  luaunit.assertTrue(self.mapView:isExplored(posAt(0, 0)))
end

os.exit(luaunit.LuaUnit.run())
