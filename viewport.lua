local viewport = {}

Viewport = {
  screenx = 0,
  screeny = 0,
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  visible = {
    startx = 0,
    starty = 0,
    endx = 0,
    endy = 0,
    offsetx = 0,
    offsety = 0
  },
  entityManager = {}
}

function Viewport:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Viewport:draw()
  self:drawMap()
  self:drawEntities()
  self:drawCursorHighlights()
end

function Viewport:drawCursorHighlights()
  local cursors = self.entityManager:getByType("cursor")
  local id, _ = next(cursors)
  local pos = self.entityManager:getByType("position")[id]
  local x, y = self:mapToScreen(pos)
  local tilew, tileh = self.tileset:tileSize()
  love.graphics.rectangle('line', x, y, tilew, tileh)
end

function Viewport:drawEntities()
  local drawables = self.entityManager:getByType("drawable")
  local v = self.visible

  for id, drawable in ipairs(drawables) do
    local pos = self.entityManager:getByType("position")[id]
    if pos and self:isVisible(pos) then
      local drawx, drawy = self:mapToScreen(pos)
      love.graphics.draw(self.tileset.units, self.tileset.unit[drawable.img], drawx, drawy, 0, 0.5, 0.5)
    end
  end
end

function Viewport:drawMap()
  local drawX, drawY = self.screenx, self.screeny
  local tileW, tileH = self.tileset:tileSize()
  local v = self.visible

  local mapX, mapY = 0, 0
  for i = v.starty, v.endy do
    local row = self.map['tiles'][i]
    mapY = i * tileH
    for j = v.startx, v.endx do
      local col = row[j]
      mapX = j * tileW
      self.tileset:draw(drawX - v.offsetx, drawY - v.offsety, col)
      drawX = drawX + tileW
    end
    drawX = self.screenx
    drawY = drawY + tileH
  end

  love.graphics.rectangle('line', self.screenx, self.screeny, self.w, self.h)
end

function Viewport:resize(w, h)
  self.w = w
  self.h = h

  tilew, tileh = self.tileset:tileSize()
  self.maxx = (self.map.width * tilew) - self.w - 1
  self.maxy = (self.map.height * tileh) - self.h - 1

  self:calculateBounds()
end

function Viewport:calculateBounds()
  local tileW, tileH = self.tileset:tileSize()

  local starty = 1 + math.floor(self.y / tileH)
  local endy = 1 + math.floor((self.y + self.h) / tileH)

  local startx = 1 + math.floor(self.x / tileW)
  local endx = 1 + math.floor((self.x + self.w) / tileW)

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

function Viewport:mapToScreen(pos)
  local tilew, tileh = self.tileset:tileSize()
  return (pos.x * tilew) - self.x + self.screenx, (pos.y * tileh) - self.y + self.screeny
end

function Viewport:screenToMap(x, y)
  local tilew, tileh = self.tileset:tileSize()
  return math.floor((x - self.screenx + self.x) / tilew), math.floor((y - self.screeny + self.y) / tileh)
end

function Viewport:isVisible(pos)
  return self.visible.startx <= pos.x + 1 and pos.x < self.visible.endx
      and self.visible.starty <= pos.y + 1 and pos.y < self.visible.endy
end

return viewport
