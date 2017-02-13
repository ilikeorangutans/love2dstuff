luaunit = require('luaunit')
pretty = require('pl.pretty')
ui = require('ui/widgets')
box = require('ui/boxmodel')

empty = {x=0,y=0,w=0,h=0}

function testFoo()
  b = box.Model:new()
  b:init()

  luaunit.assertEquals(b.dimensions, empty)
  luaunit.assertEquals(b.margin, {top=0,right=0,bottom=0,left=0})
  luaunit.assertEquals(b.marginArea, empty)
  luaunit.assertEquals(b.widgetArea, empty)
end

function testBlar()
  p = ui.Panel:new()
  p:setDimensions(0, 0, 200, 200)
  p:setBounds(11, 11, 400, 400)

  p:layout()

  bounds = {x=11,y=11,w=400,h=400}

  luaunit.assertEquals(p.bounds, bounds)
  luaunit.assertEquals(p.marginArea, bounds)
  luaunit.assertEquals(p.widgetArea, {x=11,y=11,w=200,h=200})
end

function testFillAlignment()
  p = ui.Panel:new()
  p:setDimensions(0, 0, 200, 200)
  p:setBounds(11, 11, 400, 400)
  p:setMargin(13, 13, 13, 13)
  p:setAlignment('fill', 'top')

  p:layout()

  bounds = {x=11,y=11,w=400,h=400}

  luaunit.assertEquals(p.bounds, bounds)
  luaunit.assertEquals(p.marginArea, {x=11+13, y=11+13, w=400-13-13, h=400-13-13})
  luaunit.assertEquals(p.widgetArea, {x=11+13, y=11+13, w=400-13-13, h=200})
end

function testFillNested()
  p = ui.Panel:new()
  p:setDimensions(0, 0, 200, 200)
  p:setBounds(11, 11, 400, 400)
  p:setAlignment('center', 'top')

  c = p:add(ui.VerticalContainer:new())
  c:setAlignment('fill', 'fill')
  c:setMargin(13, 13, 13, 13)

  luaunit.assertEquals(p.margin, {top=0, right=0, bottom=0, left=0})
  luaunit.assertEquals(c.margin, {top=13, right=13, bottom=13, left=13})

  p:layout()

  bounds = {x=11,y=11,w=400,h=400}

  luaunit.assertEquals(p.widgetArea, {x=111, y=11, w=200, h=200})

  luaunit.assertEquals(c.bounds, p.widgetArea)
  luaunit.assertEquals(c.marginArea, {x=111+13, y=11+13, w=174, h=174})
end

os.exit(luaunit.LuaUnit.run())
