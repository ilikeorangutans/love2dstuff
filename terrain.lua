TerrainTypes = {
  ocean = {
    title = 'Ocean',
    terrain = 'ocean',
    produces = {
      fish = 4,
    }
  },
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
  coniferforrest = {
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
  local index = (#TerrainTypesByID) + 1
  TerrainTypesByID[index] = v
end
