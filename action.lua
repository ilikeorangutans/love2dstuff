ActionSystem = {}
function ActionSystem:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ActionSystem:update(dt)

end

function ActionSystem:replenish(owner)
  local entities = self.entityManager:getComponentsByType('action', {owner=ownedBy(owner)})
  for id, comps in pairs(entities) do
    comps.action.available = comps.action.maxPoints
  end
end

function ActionSystem:onNewTurn(e)
  self:replenish(e.player)
end
