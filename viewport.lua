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
    offsety = 0,
    widthInTiles = 0,
    heightInTiles = 0
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
  local cursors = self.entityManager:getComponentsByType("cursor", "position")
  local id, comps = next(cursors)
  local pos = comps["position"]
  local x, y = self:mapToScreen(pos)
  local tilew, tileh = self.tileset:tileSize()
  love.graphics.rectangle('line', x, y, tilew, tileh)
end

function Viewport:drawEntities()
  local predicate = function(comp)
    return self:isVisible(comp)
  end
  local entities = self.entityManager:getComponentsByType("drawable", {position=predicate}, "selectable")

  for id, comps in pairs(entities) do
    local drawx, drawy = self:mapToScreen(comps.position)
    local selected = self.entityManager:getComponents("selectable")[id]
    if comps.selectable.selected then
      love.graphics.rectangle('line', drawx, drawy, 32, 32)
    end

    local img = nil
    local quad = nil
    if comps.drawable.img == "colony" then
      img = self.tileset.cities
    else
      img = self.tileset.units
    end
    quad = self.tileset.unit[comps.drawable.img]
    love.graphics.draw(img, quad, drawx, drawy, 0, 0.5, 0.5)

    local all = self.entityManager:get(id)
    if all.colony then
      love.graphics.print(all.colony.name, drawx, drawy+32)
    end
  end
end

function Viewport:drawMap()
  local drawX, drawY = self.screenx, self.screeny
  local tileW, tileH = self.tileset:tileSize()
  local v = self.visible

  local mapX, mapY = 0, 0
  for i = v.starty, v.endy do
    local row = self.map.tiles[i]
    mapY = i * tileH
    for j = v.startx, v.endx do
      local tile = row[j]
      mapX = j * tileW

      if tile.terrain.below then
        self.tileset:draw(drawX - v.offsetx, drawY - v.offsety, tile.terrain.below)
      end
      self.tileset:draw(drawX - v.offsetx, drawY - v.offsety, tile.type)
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

  local tilew, tileh = self.tileset:tileSize()
  self.maxx = (self.map.width * tilew) - self.w - 1
  self.maxy = (self.map.height * tileh) - self.h - 1
  self.visible.widthInTiles = math.ceil(w / tilew)
  self.visible.heightInTiles = math.ceil(h / tileh)

  self:calculateBounds()
end

function Viewport:calculateBounds()
  local tileW, tileH = self.tileset:tileSize()

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

--- Moves the viewport to the x and y position; not tile coordinate.
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

function Viewport:center(pos)
  local tilew, tileh = self.tileset:tileSize()
  local x = ((pos.x - (self.visible.widthInTiles / 2)) * tilew) + (tilew/2)
  local y = ((pos.y - (self.visible.heightInTiles / 2)) * tileh) + (tileh/2)
  self:moveTo(x, y)
end

function Viewport:mapToScreen(pos)
  local tilew, tileh = self.tileset:tileSize()
  return (pos.x * tilew) - self.x + self.screenx, (pos.y * tileh) - self.y + self.screeny
end

function Viewport:screenToMap(x, y)
  local tilew, tileh = self.tileset:tileSize()
  return math.floor((x - self.screenx + self.x) / tilew), math.floor((y - self.screeny + self.y) / tileh)
end

--- Returns true if the given map coordinate is visible.
function Viewport:isVisible(pos)
  return self.visible.startx <= pos.x and pos.x <= self.visible.endx and self.visible.starty <= pos.y and pos.y <= self.visible.endy
end

function Viewport:onScroll(event)
  self:moveBy(event.deltax, event.deltay)
end
