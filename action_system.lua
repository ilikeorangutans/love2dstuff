ActionSystem = {}

function ActionSystem:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ActionSystem:update(dt)
  local predicate = function(comp)
    return comp.active and (#comp.queue) > 0 and comp.points.left > 0 and comp.current
  end
  local entities = self.entityManager:getComponentsByType({action = predicate})

  for id, comps in pairs(entities) do
    self:simulate(dt, id, comps)
  end
end

function ActionSystem:simulate(dt, id, comps)
  local index, cmd = next(comps.action.queue)

  comps.action.time = comps.action.time + dt
  local itsTime = comps.action.time > comps.action.points.timePerPoint

  if itsTime then
    local action = comps.action.current.action

    if self.handlers[action] then
      -- TODO: check return value? could indicate aborted action?
      self.handlers[action](comps.action.current, id)
    end

    comps.action.time = 0
    comps.action:consumePoint(id)

    -- TODO the following check is a bit inelegant. It implies the caller needs to know about points. Should just say isDone?()
    -- What about actions that run longer, like move commands?
    if comps.action.points.needed == 0 then
      comps.action:done()
    end
  end
end

function ActionSystem:replenish(owner)
  local entities = self.entityManager:getComponentsByType('action', ownedBy(owner))
  for id, comps in pairs(entities) do
    comps.action:replenish()
  end
end

function ActionSystem:onNewTurn(e)
  self:replenish(e.player)
end

