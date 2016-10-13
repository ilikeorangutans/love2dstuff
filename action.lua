ActionComponent = {}
function ActionComponent:new(points)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.points = {}
  o.points.left = 0
  o.points.max = points
  o.points.needed = 0
  o.queue = {}
  o.time = 0
  o.current = nil

  return o
end

function ActionComponent:enqueue(cmd)
  table.insert(self.queue, cmd)
end

function ActionComponent:execute()
  if self.points.left == 0 then return end
  if (not self.current) and (#self.queue) == 0 then return end

  if not self.current then
    _, self.current = next(self.queue)
  end

  local requiredPoints = 0
  local action = self.current.action
  if action == 'nothing' then
    requiredPoints = self.points.left
  elseif action == 'move' then
    requiredPoints = 2
  end

  self.points.needed =  requiredPoints
end

function ActionComponent:consumePoint()
  if self.points.left < 1 then return end
  self.points.left = self.points.left - 1
  self.points.needed = self.points.needed - 1
end

--- Called when the current command is done.
function ActionComponent:done()
  local id, _ = next(self.queue)
  self.current = nil
  table.remove(self.queue, id)
end

function ActionComponent:replenish()
  self.points.left = self.points.max
end

ActionSystem = {}
function ActionSystem:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ActionSystem:update(dt)
  local predicate = function(comp)
    return (#comp.queue) > 0 and comp.points.left > 0 and comp.current
  end
  local entities = self.entityManager:getComponentsByType({action = predicate})

  for id, comps in pairs(entities) do
    self:simulate(dt, id, comps)
  end
end

function ActionSystem:simulate(dt, id, comps)
  local index, cmd = next(comps.action.queue)

  comps.action.time = comps.action.time + dt

  local itsTime = comps.action.time > .2

  if itsTime then
    comps.action.time = 0
    comps.action:consumePoint()

    -- TODO the following check is a bit inelegant. It implies the caller needs to know about points. Should just say isDone?()
    -- What about actions that run longer, like move commands?
    if comps.action.points.needed == 0 then
      comps.action:done()
    end
  end
end

function ActionSystem:replenish(owner)
  local entities = self.entityManager:getComponentsByType('action', {owner=ownedBy(owner)})
  for id, comps in pairs(entities) do
    comps.action:replenish()
  end
end

function ActionSystem:onNewTurn(e)
  self:replenish(e.player)
end
