pretty = require('pl.pretty')
Map = {}

function Map:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.tiles = {}

  return o
end

--- Returns a tile at a given position
-- errors if the position is outside of the map
function Map:getAt(pos)
  assert(pos and pos.x and pos.y, "position must be given")
  return self.tiles[self:posToIndex(pos)]
end

function Map:fromString(w, h, input)
  assert(w*h==#input, "input length doesn't match map size")

  self.width = w
  self.height = h

  self.tiles = {}

  for i = 1, #input do
    local t = tonumber(input:sub(i, i))
    local mapIndex = i - 1
    self.tiles[mapIndex] = {
      type = t,
      terrain = TerrainTypesByID[t]
    }
  end
end

function Map:posToIndex(pos)
  assert(self:isValid(pos), ("Invalid position %d/%d"):format(pos.x, pos.y))
  return self.width * pos.y + pos.x
end

function Map:isValid(pos)
  return 0 <= pos.x and pos.x < self.width and 0 <= pos.y and pos.y < self.height
end

function Map:getArea(start, stop)
  self:getAt(start)
  self:getAt(stop)

  local row = start.y
  local col = start.x

  return function()
    if row > stop.y then return nil end

    local pos = posAt(col, row)
    local tile = self.tiles[self:posToIndex(pos)]

    col = col + 1
    if col > stop.x then
      col = start.x
      row = row + 1
    end

    return pos, tile
  end
end

function Map:randomize(w, h)
  self.width = w
  self.height = h

  for i=0, w*h do
    local x = math.random(4)
    local t = TerrainTypesByID[x]
    self.tiles[i] = {
      type = x,
      terrain = t,
    }
  end
end

MapView = {}

function MapView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.map, "MapView requires map")
  assert(o.player, "MapView requires player")

  o.explored = {}
  o.visible = {}
  o.width = o.map.width
  o.height = o.map.height

  for i = 0, o.width*o.height do
    o.explored[i] = false
    o.visible[i] = false
  end

  o.unexplored = {
    type = 0,
    terrain = TerrainTypes.unexplored
  }

  return o
end

function MapView:getAt(pos)
  local tile = self.map:getAt(pos)
  if not self:isExplored(pos) then return self.unexplored end
  return tile
end

function MapView:getArea(start, stop)
  local iterator = self.map:getArea(start, stop)
  return function()
    local pos, tile = iterator()
    if pos == nil then return nil end
    if not self:isExplored(pos) then
      tile = self.unexplored
    end
    return pos, tile
  end
end

function MapView:isExplored(pos)
  return self.explored[self.map:posToIndex(pos)]
end

function MapView:setExplored(pos)
  self.explored[self.map:posToIndex(pos)] = true
end

function MapView:isVisible(pos)
  -- TODO for now until we have implement the active visibility system
  -- return self.visible[self.map:posToIndex(pos)]
  return self:isExplored(pos)
end

function MapView:onEntityCreated(e)
  if not e.components.vision then return end
  if not e.components.owner then return end
  if not e.components.position then return end
  if e.components.owner.id ~= self.player.id then
    return
  end

  self:updateVisibility(e.components)
end

function MapView:onPositionChanged(e)
  self:updateVisibility(e.components)
end

function MapView:onEntityDestroyed(e)
end

function MapView:updateVisibility(entity)
  local pos = entity.position
  for y = pos.y-1,pos.y+1 do
    for x = pos.x-1,pos.x+1 do
      local p = posAt(x, y)
      if self.map:isValid(p) then
        self:setExplored(p)
      end
    end
  end
end
