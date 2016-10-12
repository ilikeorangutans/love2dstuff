ActionComponent = {}
function ActionComponent:new(points)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.points = {}
  o.points.left = 0
  o.points.max = points
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

  comps.action.time = comps.action.time + dt -- TODO this should go into some kind of "animation" time

  if comps.action.time > .2 then
    comps.action.time = 0
    comps.action.points.left = comps.action.points.left - 1
  end

  if comps.action.points.left == 0 then
    -- TODO properly calculate how many points are needed for a task
    comps.action:done()
    -- TODO fire off event that something is finished?
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

IdleAction = {}
function IdleAction:new()
  return {}
end
