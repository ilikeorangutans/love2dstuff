Map = {}

function Map:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.tiles = {}

  return o
end

function Map:get(pos)
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

Goods = {
  corn = {
    title = 'Corn',
  },
  fish = {
    title = 'Fish',
  },
  tobacco = {
    title = 'Tobacco',
  },
  sugar = {
    title = 'Sugar',
  },
  lumber = {
    title = 'Lumber',
  },
  tobacco = {
    title = 'Tobacco',
  },
  furs = {
    title = 'Furs',
  },
}

TerrainTypes = {
  grassland = {
    title = 'Grassland',
    terrain = 'land',
    produces = {
      corn = 3,
      tobacco = 3,
    }
  },
  savannah = {
    title = 'Savannah',
    terrain = 'land',
    produces = {
      corn = 4,
      sugar = 3,
    }
  },
  ocean = {
    title = 'Ocean',
    terrain = 'ocean',
    produces = {
      fish = 4,
    }
  },
  coniferforrest = {
    title = 'Conifer Forrest',
    terrain = 'land',
    below = 'grassland',
    produces = {
      corn = 2,
      tobacco = 1,
      furs = 2,
      lumber = 6,
    }
  }
}
