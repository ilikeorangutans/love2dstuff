Building = {}
function Building:new(o)
  assert(o.name, "Building needs name")
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Building:produce(warehouse)
  local result = {}
  if not self.produces then return result end

  result[self.produces] = self.baseProduction
  return result
end

Buildings = {
  TownHall = Building:new({
    name="Town Hall",
    produces="libertybells",
    baseProduction=1,
    slots=3,
  }),
  Chapel = Building:new({
    name="Chapel",
    produces="crosses",
    baseProduction=1,
    slots=0,
  }),
}
