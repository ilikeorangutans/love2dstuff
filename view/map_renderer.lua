local ui = require('ui/widgets')

MapRenderer = ui.Widget:new()

function MapRenderer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.tileset, "tileset needed")
  assert(o.map, "map needed")
  assert(o.x, "x needed")
  assert(o.y, "y needed")
  assert(o.viewport, "viewport needed")

  ui.Widget.init(self)

  return o
end

function MapRenderer:draw()
  love.graphics.setColor(255, 255, 255, 255)
  local tileW, tileH = self.tileset:tileSize()
  local v = self.viewport.visible

  local area = self.map:getArea(posAt(v.startx, v.starty), posAt(v.endx, v.endy))
  for pos, tile in area do
    local x, y = self.viewport:mapToScreen(pos)

    self.tileset:draw(x, y, tile.type)
  end
end

function MapRenderer:mousepressed(x, y, button, istouch)
end

function MapRenderer:mousemoved(x, y)
end

function MapRenderer:mousereleased(x, y, button, istouch)
end

function MapRenderer:layout()
  ui.Widget.layout(self)

  self.viewport.screenx = self.widgetArea.x
  self.viewport.screeny = self.widgetArea.y
  self.viewport:resize(self.widgetArea.w, self.widgetArea.h)
end

function MapRenderer:resize(w, h)
  ui.Widget.resize(self, w, h)
  self.viewport:resize(self.widgetArea.w, self.widgetArea.h)
end

