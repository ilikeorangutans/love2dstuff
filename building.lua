Building = {}
function Building:new(t)
  assert(o.name, "Building needs name")
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.buildingType = t
  o.workers = {}
  return o
end

function Building:name()
  return self.buildingType.name
end

function Building:totalSlots()
  return self.buildingType.slots
end

function Building:availableSlots()
  return self:totalSlots() - #(self.workers)
end

function Building:produce(warehouse)
  if not self.buildingType.produces then return result end

  local goods = self.buildingType.produces
  local output = 0
  if self.buildingType.passiveProduction then
    output = output + self.buildingType.passiveProduction
  end

  for _, worker in  pairs(self.workers) do
    output = output + worker:produce(goods)
  end

  -- TODO: here we would check for raw resources needed.

  local result = {}
  result[goods.id] = output
  return result
end

function Building:addWorker(colonist)
  assert(self:availableSlots() > 0, "No available slots in building")
  table.insert(self.workers, colonist)
end

-- TODO: concept of a work site is interesting. But seems superfluous. We can just have productions for everything, and have the productions keep track of the slots, workers, etc. Right now nothing seems to be gained by a separate concept of a work site.
-- TODO: or maybe, i'll just rename productions into worksites.

BuildingTypes = {
  TownHall = {
    name="Town Hall",
    produces=Goods.libertybells,  -- goods produced here
    passiveProduction=1,      -- number of goods produced even if no worker is available
    slots=3,                  -- number of worker slots, can be 0
  },
  Chapel = {
    name="Chapel",
    produces=Goods.crosses,
    passiveProduction=1,
    slots=0,
  },
  build = function(t)
    print(t)
    return Building:new(BuildingTypes[t])
  end,
}
