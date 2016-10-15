ColonySystem = {}

function ColonySystem:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ColonySystem:foundColony(owner, pos, name)
  local drawable = {img='colony'}
  local id = self.entityManager:create({
    drawable=drawable,
    position=pos,
    selectable={},
    owner={id=owner.id},
    colony={name=name},
  })

  self.entityManager:create({
    position=pos,
    owner={id=owner.id},
    workedBy={colony=id},
  })

  return id
end

function ColonySystem:update(dt)
end

function ColonySystem:onNewTurn(e)
  print("ColonySystem:onNewTurn", e.player.name)
  local entities = self.entityManager:getComponentsByType({owner=ownedBy(e.player)}, 'colony', 'position')

  for id, comps in pairs(entities) do
    print(id, comps.colony.name)

    local worked = self:workedTiles(comps.position, e.player, id)
    for i, comps in pairs(worked) do
      local pos = comps.position
      local tile = self.map:get(pos)
      print("   worked tile at", pos.x, pos.y, tile.terrain.title)
      for k, v in pairs(tile.terrain.produces) do
        print(k, v)
      end
    end
  end
end

function ColonySystem:workedTiles(pos, owner, colony)
  local predicate = function(comp)
    return comp.colony==colony
  end
  return self.entityManager:getComponentsByType(
    {owner=ownedBy(owner)},
    {workedBy=predicate},
    'position'
  )
end
