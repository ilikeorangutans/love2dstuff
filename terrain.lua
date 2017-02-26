local TerrainDefinitions = {
  unexplored = {
    id = 0,
    title = 'Unexplored',
    terrain = 'unexplored',
    produces = {},
    generator = {
      temperatures = {
      },
    }
  },
  shippinglane = {
    id = 1,
    title = 'Shipping Lane',
    terrain = 'ocean',
    produces = {},
    generator = {
      temperatures = {
      },
    }
  },
  ocean = {
    id = 2,
    title = 'Ocean',
    terrain = 'ocean',
    produces = {
      fish = 4,
    },
    generator = {
      temperatures = {
      },
    }
  },
  arctic = {
    id = 3,
    title = 'Arctic',
    terrain = 'land',
    produces = {},
    generator = {
      temperatures = {
        0.8,
        0.3,
      },
    }
  },
  borealforest = {
    id = 4,
    title = 'Boreal forest',
    terrain = 'land',
    produces = {
      corn = 2,
      lumber = 4,
      ore = 1
    },
    generator = {
      temperatures = {
        0.1,
        0.4,
        0.2
      },
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
    },
    generator = {
      temperatures = {
        0.0,
        0.0,
        0.1,
        0.3,
        0.5,
        0.8,
        0.8,
        0.5,
        0.2,
        0.1
      },
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
    },
    generator = {
      temperatures = {
        0.0,
        0.0,
        0.1,
        0.4,
        0.7,
        0.7,
        0.4,
        0.3,
        0.2,
        0.1
      },
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
    },
    generator = {
      temperatures = {
        0.0,
        0.0,
        0.05,
        0.05,
        0.05,
        0.05,
        0.05,
        0.05,
        0.05,
        0.1
      },
    }
  },
  grassland = {
    id = 8,
    title = 'Grassland',
    terrain = 'land',
    produces = {
      corn = 3,
      tobacco = 3,
    },
    generator = {
      temperatures = {
        0.0,
        0.0,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.1
      },
    }
  },
  hills = {
    id = 9,
    title = 'Hills',
    terrain = 'land',
    produces = {
      corn = 2,
      ore = 4
    },
    generator = {
      temperatures = {
        0.1,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2
      },
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
    },
    generator = {
      temperatures = {
        0.0,
        0.0,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2
      },
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
    },
    generator = {
      temperatures = {
        0.0, -- 1
        0.0,
        0.1,
        0.2,
        0.3,
        0.4,
        0.5,
        0.7,
        0.5,
        0.2, -- 10
      },
    }
  },
  mountains = {
    id = 12,
    title = 'Mountains',
    terrain = 'land',
    produces = {
      ore = 4,
      silver = 1
    },
    generator = {
      temperatures = {
        0.1, -- 1
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.2, -- 10
      },
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
    },
    generator = {
      temperatures = {
        0.0, -- 1
        0.0,
        0.1,
        0.2,
        0.3,
        0.4,
        0.5,
        0.7,
        0.5,
        0.2, -- 10
      },
    }
  },
  prairie = {
    id = 14,
    title = 'Prairie',
    terrain = 'land',
    produces = {
      corn = 3,
      cotton = 3
    },
    generator = {
      temperatures = {
        0.0, -- 1
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.1,
        0.5,
        0.7,
        0.8, -- 10
      },
    }
  },
  rainforest = {
    id = 15,
    title = 'Rainforest',
    terrain = 'land',
    produces = {
      corn = 2,
      sugar = 1,
      lumber = 4,
      ore = 1
    },
    generator = {
      temperatures = {
        0.0, -- 1
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.1,
        0.5,
        0.6,
        0.7, -- 10
      },
    }
  },
  savannah = {
    id = 16,
    title = 'Savannah',
    terrain = 'land',
    produces = {
      corn = 4,
      sugar = 3
    },
    generator = {
      temperatures = {
        0.0, -- 1
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.2,
        0.5,
        0.6,
        0.7, -- 10
      },
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
    },
    generator = {
      temperatures = {
        0.0, -- 1
        0.0,
        0.05,
        0.05,
        0.05,
        0.05,
        0.05,
        0.05,
        0.05,
        0.05, -- 10
      },
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
    },
    generator = {
      temperatures = {
        0.0, -- 1
        0.0,
        0.1,
        0.1,
        0.1,
        0.1,
        0.1,
        0.1,
        0.1,
        0.2, -- 10
      },
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
    },
    generator = {
      temperatures = {
        0.0, -- 1
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.2,
        0.6,
        0.7,
        0.8, -- 10
      },
    }
  },
  tundra = {
    id = 20,
    title = 'Tundra',
    terrain = 'land',
    produces = {
      ore = 2,
    },
    generator = {
      temperatures = {
        0.4, -- 1
        0.8, -- 2
        0.2 -- 3
      },
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
    },
    generator = {
      temperatures = {
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.1,
        0.2,
        0.4,
        0.6
      },
    }
  },
  ice = {
    id = 22,
    title = 'Ice',
    terrain = 'ocean',
    produces = {},
    generator = {
      temperatures = {
        0.8,
        0.1
      },
    }
  },
}

TerrainTypes = {}
TerrainTypesByID = {}

function loadTerrainTypes()
  for handle, def in pairs(TerrainDefinitions) do
    def.handle = handle
    TerrainTypes[handle] = def
    TerrainTypesByID[def.id] = def
  end
end
