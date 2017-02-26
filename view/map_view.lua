local ui = require('ui/widgets')
local util = require('ui/utils')
local maprenderer = require('view/map_renderer')
local entityrenderer = require('view/entity_renderer')

MapView = ui.Widget:new()

function MapView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.viewport, "viewport needed")
  assert(o.bus, "bus needed")
  assert(o.entityManager, "entity manager needed")

  ui.Widget.init(o)

  o.mapRenderer = maprenderer.MapRenderer:new({ x=0, y=0, tileset=o.tileset, map=o.map, viewport=o.viewport, bus=o.bus })
  o.mapRenderer:setAlignment('fill', 'fill')

  o.entityRenderer = entityrenderer.Renderer:new({ entityManager=o.entityManager, map=o.map, tileset=o.tileset, viewport=o.viewport, bus=o.bus})
  o.entityRenderer:setAlignment('fill', 'fill')

  return o
end

function MapView:draw()
  self.mapRenderer:draw()
  self.entityRenderer:draw()
end

function MapView:layout()
  ui.Widget.layout(self)
  self.mapRenderer:layout()
  self.entityRenderer:layout()
end

function MapView:setBounds(x, y, w, h)
  ui.Widget.setBounds(self, x, y, w, h)
  self.mapRenderer:setBounds(x, y, w, h)
  self.entityRenderer:setBounds(x, y, w, h)
  self.viewport:setBounds(x, y, w, h)
end

function MapView:resize(w, h)
  ui.Widget.resize(self, w, h)
  self.mapRenderer:resize(w, h)
end

function MapView:mousemoved(x, y)
  ui.Widget.mousemoved(self, x, y)
  self.mapRenderer:mousemoved(x, y)
end

function MapView:mousepressed(x, y, button, istouch)
  print("MapView:mousepressed()", x, y)
  ui.Widget.mousepressed(self, x, y, button, istouch)
  self.mapRenderer:mousepressed(x, y, button, istouch)
end

function MapView:mousereleased(x, y, button, istouch)
  ui.Widget.mousepressed(self, x, y, button, istouch)
  self.mapRenderer:mousepressed(x, y, button, istouch)
end
