luaunit = require('luaunit')
require('viewport')

TestViewport = {}

function TestViewport:setUp()
  self.vp = Viewport:new({screenx=0, screeny=0, w=320, h=160, tileW=32, tileH=32, mapWidth=100, mapHeight=100})
  self.vp:resize(320, 160)
end

function TestViewport:testInitialConditions()
  self.vp:moveTo(0,0)

  luaunit.assertEquals(self.vp.visible.startx, 0)
  luaunit.assertEquals(self.vp.visible.endx, 10)
  luaunit.assertEquals(self.vp.visible.widthInTiles, 10)
  luaunit.assertEquals(self.vp.x, 0)
  luaunit.assertEquals(self.vp.visible.offsetx, 0)
end

function TestViewport:testMoveByALittle()
  self.vp:moveBy(10,10)

  luaunit.assertEquals(self.vp.visible.startx, 0)
  luaunit.assertEquals(self.vp.visible.endx, 10)
  luaunit.assertEquals(self.vp.visible.widthInTiles, 10)
  luaunit.assertEquals(self.vp.x, 10)
  luaunit.assertEquals(self.vp.visible.offsetx, 10)
end

function TestViewport:testMoveByLots()
  self.vp:moveBy(32+13,10)

  luaunit.assertEquals(self.vp.visible.startx, 1)
  luaunit.assertEquals(self.vp.visible.endx, 11)
  luaunit.assertEquals(self.vp.visible.widthInTiles, 10)
  luaunit.assertEquals(self.vp.x, 32+13)
  luaunit.assertEquals(self.vp.visible.offsetx, 13)
end

function TestViewport:testCenterAtMiddleOfMap()
  self.vp:center({x=50,y=50})
  local expectedx = ((100 * 32) / 2) - (320/2) + 16

  luaunit.assertEquals(self.vp.visible.startx, 45)
  luaunit.assertEquals(self.vp.visible.endx, 55)
  luaunit.assertEquals(self.vp.visible.widthInTiles, 10)
  luaunit.assertEquals(self.vp.x, expectedx)
  luaunit.assertEquals(self.vp.visible.offsetx, 16)
end

function TestViewport:testIsVisible()
  luaunit.assertTrue(self.vp:isVisible({x=0,y=0}))
  luaunit.assertTrue(self.vp:isVisible({x=9,y=4}))
  luaunit.assertTrue(self.vp:isVisible({x=10,y=5}))
  luaunit.assertFalse(self.vp:isVisible({x=11,y=6}))

  self.vp:moveTo(32*30, 32*30)

  luaunit.assertFalse(self.vp:isVisible({x=29,y=29}))
  luaunit.assertTrue(self.vp:isVisible({x=30,y=30}))
  luaunit.assertTrue(self.vp:isVisible({x=40,y=35}))
  luaunit.assertFalse(self.vp:isVisible({x=41,y=36}))
end

function TestViewport:testRelative()
  self.vp:resize(100, 100)
  self.vp.screenx = 13
  self.vp.screeny = 17

  local x, y = self.vp:mapToScreen({x=0, y=0})
  luaunit.assertEquals({x, y}, {13, 17})

  local v = self.vp.visible
  luaunit.assertEquals(v, {})
end

function TestViewport:testMoveToEnd()
  self.vp:moveBy(self.vp.mapWidth * 32 + 10, 0)

  luaunit.assertEquals(self.vp.visible.endx, 99)
end

os.exit(luaunit.LuaUnit.run())
