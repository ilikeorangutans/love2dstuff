TerrainTypes = {
  unexplored = {
    id = 0,
    title = 'Unexplored',
    terrain = 'unexplored',
    produces = {}
  },
  shippinglane = {
    id = 1,
    title = 'Shipping Lane',
    terrain = 'ocean',
    produces = {}
  },
  ocean = {
    id = 2,
    title = 'Ocean',
    terrain = 'ocean',
    produces = {
      fish = 4,
    }
  },
  arctic = {
    id = 3,
    title = 'Arctic',
    terrain = 'land',
    produces = { }
  },
  borealforest = {
    id = 4,
    title = 'Boreal forest',
    terrain = 'land',
    produces = {
      corn = 2,
      lumber = 4,
      ore = 1
    }
  },
  broadleafforest = {
    id = 5,
    title = 'Broadleaf forest',
    terrain = 'land',
    produces = {
      corn = 2,
      lumber = 4,
      cotton = 1
    }
  },
  coniferforrest = {
    id = 6,
    title = 'Conifer Forrest',
    terrain = 'land',
    below = 2,
    produces = {
      corn = 2,
      tobacco = 1,
      lumber = 6
    }
  },
  desert = {
    id = 7,
    title = 'Desert',
    terrain = 'land',
    produces = {
      corn = 2,
      cotton = 1,
      ore = 2
    }
  },
  grassland = {
    id = 8,
    title = 'Grassland',
    terrain = 'land',
    produces = {
      corn = 3,
      tobacco = 3,
    }
  },
  hills = {
    id = 9,
    title = 'Hills',
    terrain = 'land',
    produces = {
      corn = 2,
      ore = 4
    }
  },
  marsh = {
    id = 10,
    title = 'Marsh',
    terrain = 'land',
    produces = {
      corn = 3,
      ore = 2,
      tobacco = 2
    }
  },
  mixedforest = {
    id = 11,
    title = 'Mixed forest',
    terrain = 'land',
    produces = {
      corn = 3,
      cotton = 1,
      lumber = 6
    }
  },
  mountains = {
    id = 12,
    title = 'Mountains',
    terrain = 'land',
    produces = {
      ore = 4,
      silver = 1
    }
  },
  plains = {
    id = 13,
    title = 'Plains',
    terrain = 'land',
    produces = {
      corn = 5,
      cotton = 2,
      ore = 1
    }
  },
  prairie = {
    id = 14,
    title = 'Prairie',
    terrain = 'land',
    produces = {
      corn = 3,
      cotton = 3
    }
  },
  rainforest = {
    id = 15,
    title = 'rainforest',
    terrain = 'land',
    produces = {
      corn = 2,
      sugar = 1,
      lumber = 4,
      ore = 1
    }
  },
  savannah = {
    id = 16,
    title = 'Savannah',
    terrain = 'land',
    produces = {
      corn = 4,
      sugar = 3
    }
  },
  scrubforest = {
    id = 17,
    title = 'Scrub forest',
    terrain = 'land',
    produces = {
      corn = 2,
      cotton = 1,
      lumber = 4,
      ore = 1
    }
  },
  swamp = {
    id = 18,
    title = 'Swamp',
    terrain = 'land',
    produces = {
      corn = 3,
      sugar = 2,
      ore = 2
    }
  },
  tropicalforest = {
    id = 19,
    title = 'Tropical forest',
    terrain = 'land',
    produces = {
      corn = 3,
      sugar = 1,
      lumber = 4
    }
  },
  tundra = {
    id = 20,
    title = 'Grassland',
    terrain = 'land',
    produces = {
      ore = 2,
    }
  },
  wetlandforest = {
    id = 21,
    title = 'Wetland forest',
    terrain = 'land',
    produces = {
      corn = 2,
      tobacco = 1,
      ore = 1,
      lumber = 4
    }
  }
}

print("Loading  terrain types")
TerrainTypesByID = {}
function loadTerrainTypes()
  print("Loading terrain definitions")
  for t, v in pairs(TerrainTypes) do
    --local index = (#TerrainTypesByID)
    print("  adding ", t, v.id)
    -- v.id = t
    -- TerrainTypes[t].id = t
    TerrainTypesByID[v.id] = v
    print(pretty.dump(v))
  end
end
loadTerrainTypes()
