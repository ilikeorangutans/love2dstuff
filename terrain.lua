TerrainTypes = {
  unexplored = {
    id = 0,
    title = 'Unexplored',
    terrain = 'unexplored',
    produces = {}
  },
  ocean = {
    id = 1,
    title = 'Ocean',
    terrain = 'ocean',
    produces = {
      fish = 4,
    }
  },
  grassland = {
    id = 2,
    title = 'Grassland',
    terrain = 'land',
    produces = {
      corn = 3,
      tobacco = 3,
    }
  },
  savannah = {
    id = 3,
    title = 'Savannah',
    terrain = 'land',
    produces = {
      corn = 4,
      sugar = 3,
    }
  },
  coniferforrest = {
    id = 4,
    title = 'Conifer Forrest',
    terrain = 'land',
    below = 2,
    produces = {
      corn = 2,
      tobacco = 1,
      furs = 2,
      lumber = 6,
    }
  }
}

TerrainTypesByID = {}
for t, v in pairs(TerrainTypes) do
  local index = (#TerrainTypesByID)
  TerrainTypesByID[v.id] = v
end

