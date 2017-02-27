luaunit = require('luaunit')
require('util')
require('player')
require('terrain')
map = require('map')

TestMapView = {}

function TestMapView:setUp()
  local m = map.Map:new()
  self.map = m
  self.map:fromString(5, 5, "1111112221122211222111111")

  local player = Player:new('test')
  local mapView = map.View:new({map=m, player=player})
  self.mapView = mapView
end

function TestMapView:testIsExplored()
  luaunit.assertFalse(self.mapView:isExplored(posAt(0, 0)))
  self.mapView:setExplored(posAt(0, 0))
  luaunit.assertTrue(self.mapView:isExplored(posAt(0, 0)))
end

function TestMapView:testGetAtReturnsUnexploredForUnexploredTile()
  local tile = self.mapView:getAt(posAt(0,0))
  luaunit.assertEquals(tile, self.mapView.unexplored)
end

function TestMapView:testGetAtReturnsTile()
  self.mapView:setExplored(posAt(0, 0))
  local tile = self.mapView:getAt(posAt(0, 0))
  luaunit.assertEquals(tile, self.map:getAt(posAt(0, 0)))
end

function TestMapView:testUpdateVisibility()
  local entity = {
    position = posAt(1, 1),
    vision = {radius=1}
  }

  self.mapView:updateVisibility(entity)
  luaunit.assertTrue(self.mapView:isExplored(posAt(0, 0)))
  luaunit.assertTrue(self.mapView:isExplored(posAt(2, 2)))
end

function TestMapView:testGetArea()
  self.mapView:setExplored(posAt(0, 0))
  self.mapView:setExplored(posAt(2, 0))

  local area = self.mapView:getArea(posAt(0, 0), posAt(1, 0))

  local count = 0
  for pos, tile in area do
    count = count + 1
  end

  luaunit.assertEquals(count, 2)
end

os.exit(luaunit.LuaUnit.run())
