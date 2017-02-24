Viewport = {}

function Viewport:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.screenx, "screen x needed")
  assert(o.screeny, "screen y needed")
  assert(o.tileW, "tile width needed")
  assert(o.tileH, "tile height needed")
  assert(o.mapWidth, "map width needed")
  assert(o.mapHeight, "map height needed")

  o.visible = {}
  o.x = 0
  o.y = 0
  o.maxx = 0
  o.maxy = 0

  return o
end

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

function Viewport:calculateBounds()
  local tileW, tileH = self.tileW, self.tileH

  local starty = math.floor(self.y / tileH)
  local endy = math.floor((self.y + self.h) / tileH)

  local startx = math.floor(self.x / tileW)
  local endx = math.floor((self.x + self.w) / tileW)

  self.visible.offsetx = self.x % 32
  self.visible.offsety = self.y % 32
  self.visible.startx = startx
  self.visible.endx = endx
  self.visible.starty = starty
  self.visible.endy = endy
end

function Viewport:moveBy(deltax, deltay)
  if deltax == 0 and deltay == 0 then return end
  self:moveTo(self.x + deltax, self.y + deltay)
end

function Viewport:resize(w, h)
  self.w = w
  self.h = h

  local tilew, tileh = self.tileW, self.tileH
  self.maxx = (self.mapWidth * tilew) - self.w - 1
  self.maxy = (self.mapHeight * tileh) - self.h - 1
  self.visible.widthInTiles = math.ceil(w / tilew)
  self.visible.heightInTiles = math.ceil(h / tileh)

  self:calculateBounds()
end

function Viewport:center(pos)
  local x = ((pos.x - (self.visible.widthInTiles / 2)) * self.tileW) + (self.tileW/2)
  local y = ((pos.y - (self.visible.heightInTiles / 2)) * self.tileH) + (self.tileH/2)
  self:moveTo(x, y)
end

function Viewport:mapToScreen(pos)
  local tilew, tileh = self.tileW, self.tileH
  return (pos.x * tilew) - self.x + self.screenx, (pos.y * tileh) - self.y + self.screeny
end

function Viewport:screenToMap(x, y)
  local tilew, tileh = self.tileW, self.tileH
  return math.floor((x - self.screenx + self.x) / tilew), math.floor((y - self.screeny + self.y) / tileh)
end

function Viewport:isVisible(pos)
  local v = self.visible
  return v.startx <= pos.x and pos.x <= v.endx and v.starty <= pos.y and pos.y <= v.endy
end
