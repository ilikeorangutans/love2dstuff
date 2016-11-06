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
