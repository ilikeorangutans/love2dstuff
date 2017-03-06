ColonySystem = {}

function ColonySystem:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ColonySystem:subscribe(bus)
  bus:subscribe('game.newTurn', self, ColonySystem.onNewTurn)
end

function ColonySystem:foundColony(owner, pos, map, name)
  local drawable = {img='colony'}
  local id, comps = self.entityManager:create({
    drawable=drawable,
    visible={value=true},
    position=pos,
    selectable={selectable=true},
    owner={id=owner.id},
    colony=Colony:new({name=name}),
    vision={radius=1}
  })

  local _, tileComps = self.entityManager:create({
    position=pos,
    owner={id=owner.id},
    workedBy={
      colony=id,
      produce = function()
        -- This method sucks because it repicks what to produce every turn
        -- Also sucks because it references outside elements via closure, can't
        -- refactor this into a separate method
        local tile = map:getAt(pos)
        local maxProducts = 2
        local tileProduces = tile.terrain.produces

        local numberOfProducts = 0
        for t, amount in pairs(tileProduces) do
          numberOfProducts = numberOfProducts + 1
        end
        local produceAmount = math.min(numberOfProducts, maxProducts)

        -- TODO: this just picks the first two things, should probably ensure that we produce food.
        local result = {}
        local counter = 0
        for t, amount in pairs(tile.terrain.produces) do
          result[t] = amount
          counter = counter + 1
          if counter >= produceAmount then break end
        end

        return result
      end,
    },
  })

  -- TODO: colony should subscribe to events of the tile below it?
  -- TODO: or colony system listens to tile change events...

  table.insert(comps.colony.worksites, tileComps.workedBy)

  -- table.insert(comps.colony.worksites, {
    -- produce = function(_, warehouse)
      -- local x = 5
      -- local t, _ = next(warehouse.goods)
      -- local available = warehouse:get('sugar', x)
--
      -- local result = {
        -- rum = available
      -- }
      -- return result
    -- end
  -- })

  -- Create "worksite" that represents the colonists and the food they consume
  table.insert(comps.colony.worksites, {
    produce = function(_, warehouse)
      local FOOD_PER_COLONIST = 2
      local needed = #(comps.colony.colonists) * FOOD_PER_COLONIST
      needed = needed - comps.colony.warehouse:get('fish', needed)
      needed = needed - comps.colony.warehouse:get('corn', needed)

      if needed > 0 then
        -- TODO starve colonists?
        print(("NOT ENOUGH FOOD IN %s"):format(comps.colony.name))
      end

      return {}
    end
  })

  self:addBuilding(comps, BuildingTypes.build('TownHall'))
  self:addBuilding(comps, BuildingTypes.build('Chapel'))

  return id
end

function ColonySystem:addBuilding(colony, building)
  table.insert(colony.colony.buildings, building)
  table.insert(colony.colony.worksites, building)
end

function ColonySystem:addColonist(colony, colonist)
  assert(colony.owner.id == colonist.owner.id, "colony and colonist must belong to same owner")
  assert(colony.position.x == colonist.position.x and colony.position.y == colonist.position.y, "colony and colonist must be at the same coordinates")

  colonist.action.active = false
  colonist.visible.value = false
  table.insert(colony.colony.colonists, colonist)

  -- TODO: we're just assigning the colonist to the first building
  local _, building = next(colony.colony.buildings)
  building:addWorker(colonist.colonist)

  --self.entityManager:removeComponent(colonist.id, 'selectable')
  -- TODO: this is really fucky
  colonist.selectable.selectable = false
  self.bus:fire('colonist.joinedColony', {colony=colony, colonist=colonist})
end

function ColonySystem:update(dt)
end

function ColonySystem:onNewTurn(e)
  local player = e.player

  local entities = self.entityManager:getComponentsByType(ownedBy(e.player), 'colony', 'position')
  for id, comps in pairs(entities) do
    self:produce(id, comps)
  end

end

function ColonySystem:produce(id, comps)
  print("Production for", id, comps.colony.name, #(comps.colony.colonists))

  for k, v in pairs(comps.colony.worksites) do
    local products = v:produce(comps.colony.warehouse)
    for t, amount in pairs(products) do
      print(t, amount)
      comps.colony.warehouse:add(t, amount)
    end
  end

  print(comps.colony.warehouse:toString())
end
