local mapview = {}

MapView = {
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  startx = 0,
  endx = 0,
  starty = 0,
  endy = 0,
  offsetx = 0,
  offsety = 0
}

function MapView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function MapView:draw(viewport)
  drawX, drawY = Viewport.x, viewport.y
  tileW, tileH = self.tileset:tileSize()
  offsetx, offsety = 0, 0

  mapX, mapY = 0, 0
  for i = self.startY, self.endY do
    row = self.map['tiles'][i]
    mapY = i * tileH
    for j = self.startX, self.endX do
      col = row[j]
      mapX = j * tileW
      self.tileset:draw(drawX - self.offsetx, drawY - self.offsety, col)
      drawX = drawX + tileW
    end
    drawX = Viewport.x
    drawY = drawY + tileH
  end


  love.graphics.rectangle('line', viewport.x, viewport.y, self.w, self.h)
end

function MapView:resize(w, h)
  self.w = w
  self.h = h

  tilew, tileh = self.tileset:tileSize()
  self.maxx = (self.map.width * tilew) - self.w - 1
  self.maxy = (self.map.height * tileh) - self.h - 1

  self:calculateBounds()
end

function MapView:calculateBounds()
  tileW, tileH = self.tileset:tileSize()

  self.startY = 1 + math.floor(self.y / tileH)
  self.endY = 1 + math.floor((self.y + self.h) / tileH)

  self.startX = 1 + math.floor(self.x / tileW)
  self.endX = 1 + math.floor((self.x + self.w) / tileW)

  self.offsetx = self.x % 32
  self.offsety = self.y % 32
end

function MapView:moveBy(deltax, deltay)
  if deltax == 0 and deltay == 0 then return end
  self:moveTo(self.x + deltax, self.y + deltay)
end

function MapView:moveTo(x, y)

  if x < 0 then x = 0 end
  if x >= self.maxx then x = self.maxx end
  if y < 0 then y = 0 end
  if y >= self.maxy then y = self.maxy end

  if x == self.x and y == self.y then return end

  self.x = x
  self.y = y

  self:calculateBounds()
end

return mapview
