MapRenderer = {}
function MapRenderer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.tileset, "tileset needed")
  assert(o.map, "map needed")
  assert(o.x, "x needed")
  assert(o.y, "y needed")

  o.viewportArea = ViewportArea:new({
    screenx=o.x,
    screeny=o.y,
    w=o.w,
    h=o.h,
    tileW=o.tileset.tileW,
    tileH=o.tileset.tileH,
    mapWidth=o.map.width,
    mapHeight=o.map.height })

  return o
end

function MapRenderer:draw()
  love.graphics.setColor(255, 255, 255, 255)
  local tileW, tileH = self.tileset:tileSize()
  local v = self.viewportArea.visible

  local area = self.map:getArea(posAt(v.startx, v.starty), posAt(v.endx, v.endy))
  for pos, tile in area do
    local x, y = self.viewportArea:mapToScreen(pos)

    self.tileset:draw(x, y, tile.type)
  end
end

function MapRenderer:mousemoved(x, y)
end

function MapRenderer:resize(w, h)
  self.viewportArea:resize(w, h)
  self.w = w
  self.h = h
end

function MapRenderer:mousereleased(x, y, button, istouch)
end

ViewportArea = {}
function ViewportArea:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.screenx, "screen x needed")
  assert(o.screeny, "screen y needed")
  assert(o.w, "width needed")
  assert(o.h, "height needed")
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

function ViewportArea:moveTo(x, y)
  if x >= self.maxx then x = self.maxx end
  if x < 0 then x = 0 end
  if y >= self.maxy then y = self.maxy end
  if y < 0 then y = 0 end

  if x == self.x and y == self.y then return end

  self.x = x
  self.y = y

  self:calculateBounds()
end

function ViewportArea:calculateBounds()
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

function ViewportArea:moveBy(deltax, deltay)
  if deltax == 0 and deltay == 0 then return end
  self:moveTo(self.x + deltax, self.y + deltay)
end

function ViewportArea:resize(w, h)
  self.w = w
  self.h = h

  local tilew, tileh = self.tileW, self.tileH
  self.maxx = (self.mapWidth * tilew) - self.w - 1
  self.maxy = (self.mapHeight * tileh) - self.h - 1
  self.visible.widthInTiles = math.ceil(w / tilew)
  self.visible.heightInTiles = math.ceil(h / tileh)

  self:calculateBounds()
end

function ViewportArea:mapToScreen(pos)
  local tilew, tileh = self.tileW, self.tileH
  return (pos.x * tilew) - self.x + self.screenx, (pos.y * tileh) - self.y + self.screeny
end

