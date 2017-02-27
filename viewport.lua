local util = require('ui/utils')

Viewport = {}

--- Viewport encapsulates all logic about what part of the world we are looking at.
-- Fires events:
-- * viewport:hover if the mouse cursor hovers over a tile, contains map x and y
function Viewport:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.tileW, "tile width needed")
  assert(o.tileH, "tile height needed")
  assert(o.mapWidth, "map width needed")
  assert(o.mapHeight, "map height needed")
  assert(o.bus, "bus needed")

  o.visible = {}
  o.x = 0
  o.y = 0
  o.maxx = 0
  o.maxy = 0

  o.tileWidth = o.tileW
  o.tileHeight = o.tileH

  o.screenArea = {
    x = 0,
    y = 0,
    w = 0,
    h = 0,
  }

  o.mouse = {}

  return o
end

--- Moves the viewport to look at the given coordinates.
function Viewport:moveTo(x, y)
  if x >= self.maxx then x = self.maxx end
  if x < 0 then x = 0 end
  if y >= self.maxy then y = self.maxy end
  if y < 0 then y = 0 end

  if x == self.x and y == self.y then return end

  self.x = x
  self.y = y

  self:calculateBounds()
end

--- Moves the viewport relative to the current position.
function Viewport:moveBy(deltax, deltay)
  if deltax == 0 and deltay == 0 then return end
  self:moveTo(self.x + deltax, self.y + deltay)
end

--- Changes the size in screen coordinates of the viewport.
function Viewport:resize(w, h)
  self.screenArea.w = w
  self.screenArea.h = h

  local tilew, tileh = self.tileW, self.tileH
  self.maxx = (self.mapWidth * tilew) - w - 1
  self.maxy = (self.mapHeight * tileh) - h - 1
  self.visible.widthInTiles = math.ceil(w / tilew)
  self.visible.heightInTiles = math.ceil(h / tileh)

  self:calculateBounds()
end

function Viewport:setBounds(x, y, w, h)
  if x == self.screenArea.x and y == self.screenArea.y and w == self.screenArea.w and h == self.screenArea.h then return end

  self.screenArea.x = x
  self.screenArea.y = y
  self:resize(w, h)
end

--- Centers the viewport on the given coordinates as much as possible.
function Viewport:center(pos)
  local x = ((pos.x - (self.visible.widthInTiles / 2)) * self.tileW) + (self.tileW/2)
  local y = ((pos.y - (self.visible.heightInTiles / 2)) * self.tileH) + (self.tileH/2)
  self:moveTo(x, y)
end

--- Converts the given map coordinates to screen coordinates
function Viewport:mapToScreen(pos)
  local tilew, tileh = self.tileW, self.tileH
  return (pos.x * tilew) - self.x + self.screenArea.x, (pos.y * tileh) - self.y + self.screenArea.y
end

--- Converts the given screen coordinates to map coordinates.
function Viewport:screenToMap(x, y)
  local tilew, tileh = self.tileW, self.tileH
  -- TOOD: what if screen coordiantes are not on map?
  return math.floor((x - self.screenArea.x + self.x) / tilew), math.floor((y - self.screenArea.y + self.y) / tileh)
end

--- Checks if the given map coordinates are in the visible map area.
function Viewport:isVisible(pos)
  local v = self.visible
  return v.startx <= pos.x and pos.x <= v.endx and v.starty <= pos.y and pos.y <= v.endy
end

function Viewport:mousemoved(x, y)
  if not util.overBox(x, y, self.screenArea) then return end

  local mapx, mapy = self:screenToMap(x, y)
  if self.mouse.x == mapx and self.mouse.y == mapy then return end

  self.bus:fire("viewport:hover", {x=mapx, y=mapy})

  self.mouse.x = mapx
  self.mouse.y = mapy
end

function Viewport:mousereleased(x, y, button, istouch)
  if not util.overBox(x, y, self.screenArea) then return end
  local mapx, mapy = self:screenToMap(x, y)
  self.bus:fire("viewport:click", {x=mapx, y=mapy, button=button})
end

function Viewport:calculateBounds()
  local tileW, tileH = self.tileW, self.tileH

  local starty = math.floor(self.y / tileH)
  local endy = math.floor((self.y + self.screenArea.h) / tileH)

  local startx = math.floor(self.x / tileW)
  local endx = math.floor((self.x + self.screenArea.w) / tileW)

  self.visible.offsetx = self.x % 32
  self.visible.offsety = self.y % 32
  self.visible.startx = startx
  self.visible.endx = endx
  self.visible.starty = starty
  self.visible.endy = endy
end
