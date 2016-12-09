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
    selectable={selectable=true},
    owner={id=owner.id},
    colony={
      name=name,
      warehouse=Warehouse:new(),
    },
    visible={value=true},
    colonists={},
    vision={radius=1}
  })

  local x = self.entityManager:create({
    position=pos,
    owner={id=owner.id},
    workedBy={colony=id},
  })

  return id
end

function ColonySystem:addColonist(colony, colonist)
  assert(colony.owner.id == colonist.owner.id, "colony and colonist must belong to same owner")
  assert(colony.position.x == colonist.position.x and colony.position.y == colonist.position.y, "colony and colonist must be at the same coordinates")

  colonist.action.active = false
  colonist.visible.value = false
  self.entityManager:removeComponent(colonist.id, 'selectable')
  self.bus:fire('colonist.joinedColony', {colony=colony, colonist=colonist})
end

function ColonySystem:update(dt)
end

function ColonySystem:onNewTurn(e)
  local entities = self.entityManager:getComponentsByType(ownedBy(e.player), 'colony', 'position')

  for id, comps in pairs(entities) do
    self:produce(id, comps)
  end
end

function ColonySystem:produce(id, comps)
  print("Production for", id, comps.colony.name)

  local workedTiles = self:tilesWorkedByColony(comps.position, id)
  for i, tileComps in pairs(workedTiles) do
    local pos = tileComps.position
    local tile = self.map:getAt(pos)
    for k, v in pairs(tile.terrain.produces) do
      print(k, v)
      comps.colony.warehouse:add(k, v)
    end
  end

  print(comps.colony.warehouse:toString())
end

function ColonySystem:tilesWorkedByColony(pos, colony)
  local predicate = function(comp)
    return comp.colony==colony
  end
  return self.entityManager:getComponentsByType(
    {workedBy=predicate},
    'position'
  )
end
