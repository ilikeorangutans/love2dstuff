local mapview = {}

MapView = {
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  startx = 0,
  endx = 0,
  starty = 0,
  endy = 0
}

function MapView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function MapView:draw(viewport)
  drawX, drawY = Viewport.x, Viewport.y
  mapX, mapY = 0, 0
  tileW, tileH = self.tileset:tileSize()


  offsetx, offsety = 0, 0


  for i = self.startY, self.endY do
    row = self.map['tiles'][i]
    mapY = i * tileH
    for j = self.startX, self.endX do
      col = row[j]
      mapX = j * tileW
      self.tileset:draw(drawX, drawY, col)
      drawX = drawX + tileW
    end
    drawX = Viewport.x
    drawY = drawY + tileH
  end
end

function MapView:resize(w, h)
  self.w = w
  self.h = h

  self:calculateBounds()
end

function MapView:calculateBounds()
  self.startY = 1 + math.floor(self.y / tileH)
  self.endY = 1 + math.floor((self.y + self.h) / tileH)

  self.startX = 1 + math.floor(self.x / tileW)
  self.endX = 1 + math.floor((self.x + self.w) / tileW)

  print("MapView.x", self.x, "MapView.y", self.y, "startY", startY, "endY", endY, "startX", startX, "endX", endX)
end

function MapView:moveBy(deltax, deltay)
  if deltax == 0 and deltay == 0 then return end
  self.x = self.x + deltax
  if self.x < 0 then self.x = 0 end
  self.y = self.y + deltay
  if self.y < 0 then self.y = 0 end

  self:calculateBounds()
end

return mapview
