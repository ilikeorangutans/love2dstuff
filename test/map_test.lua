luaunit = require('luaunit')
require('util')
require('map')
require('terrain')

TestMap = {}

function TestMap:setUp()
  self.map = Map:new()
  self.map:randomize(10, 10)
end

function TestMap:testGetAt()
  local result = self.map:getAt({x=3,y=3})
  luaunit.assertNotNil(result)
  luaunit.assertEquals(result.type, 2) -- TODO: this uses randomized map, might fail
  luaunit.assertError(self.map.getAt, self.map, {x=10,y=10})
end

function TestMap:testGetAreaIteratorHasPosAndTile()
  local area = self.map:getArea(posAt(0,0), posAt(0,0))
  local pos, tile = area()

  luaunit.assertEquals(pos, {x=0, y=0})
  luaunit.assertNotNil(tile)
end

function TestMap:testGetAreaReturnsIterator()
  local topLeft = posAt(2, 2)
  local bottomRight = posAt(4, 4)
  local area = self.map:getArea(topLeft, bottomRight)

  local count = 0
  for pos, tile in area do
    count = count + 1
  end

  luaunit.assertEquals(count, 9)
end

function TestMap:testFromString()
  self.map:fromString(2, 2, "1122")

  luaunit.assertEquals(self.map:getAt(posAt(0,0)).type, 1)
  luaunit.assertEquals(self.map:getAt(posAt(1,1)).type, 2)
end

function TestMap:testPosToIndex()
  luaunit.assertEquals(self.map:posToIndex(posAt(0, 0)), 0)
  luaunit.assertEquals(self.map:posToIndex(posAt(1, 0)), 1)
  luaunit.assertEquals(self.map:posToIndex(posAt(0, 1)), 10)
  luaunit.assertEquals(self.map:posToIndex(posAt(9, 9)), 99)
end

os.exit(luaunit.LuaUnit.run())
