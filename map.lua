Map = {}

function Map:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.tiles = {}

  return o
end

function Map:getAt(pos)
  assert(pos and pos.x and pos.y, "position must be given")
  return self.tiles[pos.y][pos.x]
end

function Map:randomize(w, h)
  self.width = w
  self.height = h

  local z = {}
  for t, _ in pairs(TerrainTypes) do
    table.insert(z, t)
  end

  for row=0, h-1 do
    self.tiles[row] = {}
    for col=0, w-1 do
      local x = math.random(4)
      local t = z[x]
      self.tiles[row][col] = {
        type = t,
        terrain = TerrainTypes[t],
      }
    end
  end
end


MapView = {}
function MapView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.map, "MapView requires map")

  o.explored = {}
  o.visible = {}
  o.width = o.map.width
  o.height = o.map.height

  return o
end

function MapView:tiles()
end

function MapView:getAt(pos)
  return self.map:getAt(pos)
end

function MapView:isExplored(pos)
  return false
end

function MapView:isVisible(pos)
  return false
end
