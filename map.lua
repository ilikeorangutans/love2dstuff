Map = {}

function Map:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.tiles = {}

  return o
end

function Map:get(pos)
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

TerrainTypes = {
  grassland = {
    title = 'Grassland',
    terrain = 'land'
  },
  savannah = {
    title = 'Savannah',
    terrain = 'land'
  },
  ocean = {
    title = 'Ocean',
    terrain = 'ocean'
  },
  coniferforrest = {
    title = 'Conifer Forrest',
    terrain = 'land',
    below = 'grassland'
  }
}
