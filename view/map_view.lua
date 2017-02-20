local ui = require('ui/widgets')
local util = require('ui/utils')

MapView = ui.Widget:new()

function MapView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.viewport, "viewport needed")
  assert(o.bus, "bus needed")

  ui.Widget.init(o)

  o.mapRenderer = MapRenderer:new({ x=0, y=0, tileset=o.tileset, map=o.map, viewport=o.viewport, bus=o.bus })
  print(o.mapRenderer)
  o.mapRenderer:setAlignment('fill', 'fill')

  return o
end

function MapView:draw()
  self.mapRenderer:draw()
end

function MapView:layout()
  ui.Widget.layout(self)
  self.mapRenderer:layout()
end

function MapView:setBounds(x, y, w, h)
  ui.Widget.setBounds(self, x, y, w, h)
  self.mapRenderer:setBounds(x, y, w, h)
end

function MapView:resize(w, h)
  ui.Widget.resize(self, w, h)
  self.mapRenderer:resize(w, h)
end
