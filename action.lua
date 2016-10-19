ActionComponent = {}
function ActionComponent:new(points)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.points = {}
  o.active = true
  o.points.left = 0 -- How many points are available in this turn?
  o.points.max = points
  o.points.needed = 0 -- How many points are needed to finish this action?
  o.points.timePerPoint = 0.0 -- How much time should be spent per step consuming action points?
  o.points.consumesPoints = 1 -- How many points to consume in each step?
  o.func = nil -- Function to call on each step
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
  local timePerPoint = 0
  local consumesPoints = 1
  local action = self.current.action
  if action == 'nothing' then
    requiredPoints = self.points.left
    consumesPoints = requiredPoints
  elseif action == 'build' then
    requiredPoints = self.points.left
    consumesPoints = requiredPoints
 elseif action == 'move' then
    requiredPoints = 2
    timePerPoint = .5
  end

  self.points.needed = requiredPoints
  self.points.timePerPoint = timePerPoint
  self.points.consumesPoints = consumesPoints
end

function ActionComponent:consumePoint(entity)
  if self.points.left < self.points.consumesPoints then return end

  self.points.left = self.points.left - self.points.consumesPoints
  self.points.needed = self.points.needed - self.points.consumesPoints
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
    comps.action:consumePoint(id, self.entityManager)

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
