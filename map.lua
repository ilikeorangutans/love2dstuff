local Map = {}

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
      terrain = TerrainTypes[t]
    }
  end
end

function Map:posToIndex(pos)
  assert(self:isOnMap(pos), ("Invalid position %d/%d"):format(pos.x, pos.y))
  return self.width * pos.y + pos.x
end

function Map:isOnMap(pos)
  return 0 <= pos.x and pos.x < self.width and 0 <= pos.y and pos.y < self.height
end

--- Returns an iterator over the area defined by start and stop.
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

--- Returns an iterator over the neighbours in the given radius around the position, i.e. all neighbours but not the position.
function Map:getNeighbours(pos, radius)
  radius = radius or 1
  local start = posAt(pos.x - radius, pos.y - radius)
  local stop = posAt(pos.x + radius, pos.y + radius)
  local it = self:getArea(start, stop)

  return function()
    local p, tile = it()
    if p and p.x == pos.x and p.y == pos.y then
      p, tile = it()
    end

    return p, tile
  end
end

--- A map with fog of war.
local ExplorableMap = {}

function ExplorableMap:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.map, "ExplorableMap requires map")
  assert(o.player, "ExplorableMap requires player")

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

function ExplorableMap:subscribe(bus)
  bus:subscribe('entity.created', self, self.onEntityCreated)
  bus:subscribe('entity.destroyed', self, self.onEntityDestroyed)
  bus:subscribe('position.changed', self, self.onPositionChanged)
end

function ExplorableMap:getAt(pos)
  local tile = self.map:getAt(pos)
  if not self:isExplored(pos) then return self.unexplored end
  return tile
end

function ExplorableMap:getArea(start, stop)
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

function ExplorableMap:isExplored(pos)
  return self.explored[self.map:posToIndex(pos)]
end

function ExplorableMap:setExplored(pos)
  self.explored[self.map:posToIndex(pos)] = true
end

function ExplorableMap:isVisible(pos)
  -- TODO for now until we have implement the active visibility system
  -- return self.visible[self.map:posToIndex(pos)]
  return self:isExplored(pos)
end

function ExplorableMap:onEntityCreated(e)
  if not e.components.vision then return end
  if not e.components.owner then return end
  if not e.components.position then return end
  if e.components.owner.id ~= self.player.id then
    return
  end

  self:updateVisibility(e.components)
end

function ExplorableMap:onPositionChanged(e)
  if e.components.owner.id ~= self.player.id then return end
  self:updateVisibility(e.components)
end
function ExplorableMap:onEntityDestroyed(e)
end

function ExplorableMap:updateVisibility(entity)
  local pos = entity.position
  local radius = entity.vision.radius
  for y = pos.y-radius,pos.y+radius do
    for x = pos.x-radius,pos.x+radius do
      local p = posAt(x, y)
      if self.map:isOnMap(p) then
        self:setExplored(p)
      end
    end
  end
end

local PureRandomMapGenerator = {}
function PureRandomMapGenerator:generate(w, h)
  local map = Map:new({width = w, height = h})
  local max = 20

  for i=0, w*h do
    local x = math.random(max)
    local t = TerrainTypesByID[x]
    map.tiles[i] = {
      type = x,
      terrain = t,
    }
  end

  return map
end

local BetterRandomMapGenerator = {}
function BetterRandomMapGenerator:generate(w, h)
  local map = Map:new({width = w, height = h})

  math.randomseed(os.time())

  local border = 5 -- minimum tiles between map limits and terrain
  local tMin = 1
  local tMax = 10
  local equator = h / 2
  local tStep = equator / tMax

  -- Fill with deep ocean, initial temperature and height distribution:
  for i=0, w*h do
    local y = i / w
    local dist = math.abs(y - equator)
    local temperature = math.ceil(tMax - (dist / tStep))
    if temperature <  tMin then temperature = tMin end

    map.tiles[i] = {
      type = 1,
      terrain = TerrainTypes['shippinglane'],
      generator = {
        terrain = 'shippinglane',
        temperature = temperature,
        height = 0
      },
    }
  end

  -- randomly set terrain points with great height
  local initalPointsPercentage = .05
  local maxPoints = w*h*initalPointsPercentage
  -- idea: tectonic plate faultlines?
  for i=0, maxPoints do
    local x = math.random(border, w-border)
    local y = math.random(border, h-border)
    local height = math.random(2, 4)
    local index = (y * w) + x

    map.tiles[index].generator.height = height
  end

  -- Alter terrain based on neighbours
  local iterations = 6
  for iteration = 1, iterations do
    for y=1, h-2 do
      for x=1, w-2 do
        local i = (y * w) + x
        local tile = map.tiles[i]
        local newHeight = tile.generator.height

        local area = map:getArea(posAt(x-1, y-1), posAt(x+1, y+1))
        local area = map:getNeighbours(posAt(x, y))
        local diffBetweenNeighbours = 0

        for pos, otherTile in area do
          local diff = math.abs(tile.generator.height - otherTile.generator.height)
          diffBetweenNeighbours = diffBetweenNeighbours + diff
        end
        if math.abs(diffBetweenNeighbours) > math.random(10) then
          newHeight = math.min(newHeight + 1, 4)
        end

        tile.generator.height = math.max(tile.generator.height, newHeight)
      end
    end
  end

  -- Set terrain type based on height
  -- 0 deep ocean, 1 ocean, 2 land, 3 hills, 4 mountains
  for i=0, w*h do
    local tile = map.tiles[i]

    if tile.generator.height > 1 then
      tile.generator.terrain = 'land'
    elseif tile.generator.height == 1 then
      local def = TerrainTypes['ocean']
      tile.type = def.id
      tile.terrain = def
    end
  end


  -- pick terrain based on temperature
  for i=0, w*h do
    local tile = map.tiles[i]
    if tile.generator.terrain == 'land' then
      local t = tile.generator.temperature

      local temps = {}
      for handle, def in pairs(TerrainTypes) do
        if def.generator.temperatures[t] then
          table.insert(temps, def)
        end
      end

      for _, def in pairs(temps) do
        local prob = def.generator.temperatures[t]
        local rand = math.random()
        if rand < prob  then
          tile.type = def.id
          tile.terrain = def
          break
        end
      end
    end
  end

  return map
end

local module = {}
module.Map = Map
module.PureRandomMapGenerator = PureRandomMapGenerator
module.BetterRandomMapGenerator = BetterRandomMapGenerator
module.ExplorableMap = ExplorableMap
return module
