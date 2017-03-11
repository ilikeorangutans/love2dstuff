local function checkAction(action)
  assert(action.pointsNeeded, "action requires pointsNeeded")
  assert(action.isFinished, "action requires isFinished")
  assert(action.timePerStep, "action requires timePerStep")
  assert(action.pointsPerStep, "action requires pointsPerStep")
  assert(action.step, "action requires step")
end

local System = {}
function System:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.bus)
  assert(o.entityManager)

  return o
end

function System:subscribe()
  self.bus:subscribe("game.newTurn", self, System.onNewTurn)
end

function System:update(dt)
  local entities = self:getEntitiesToSimulate()

  local c = #(entities)
  if c > 0 then print("action.System:update() has ", c) end

  for id, comps in pairs(entities) do
    -- TODO calculate time
    comps.action:step(dt)

    if comps.action:isFinished() then
      self.bus:fire('action:complete', comps.action)
    end
  end
end

function System:getEntitiesToSimulate()
  local predicate = {
    action = function(comp)
      return comp:canStep() and comp.active
    end
  }
  return self.entityManager:getComponentsByType(predicate)
end

function System:replenish(owner)
  local entities = self.entityManager:getComponentsByType('action', ownedBy(owner))
  for id, comps in pairs(entities) do
    comps.action:replenish()
  end
end

function System:onNewTurn(e)
  print("System:onNewTurn()")
  self:replenish(e.player)
end

local Component = {}

function Component:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.points)

  o.queue = {}
  o:replenish()

  return o
end

function Component:replenish()
  self.pointsLeft = self.points
end

function Component:hasPointsLeft()
  return self.pointsLeft > 0
end

function Component:hasAction()
  return #(self.queue) > 0
end

function Component:setAction(action)
  print("Component:setAction()")
  table.insert(self.queue, 1, action)
end

function Component:canStep()
  -- TODO take into account how many points the current action would consume
  local hasEnoughPointsForStep = true
  return self:hasAction() and self:hasPointsLeft() and hasEnoughPointsForStep
end

function Component:step(dt)
  local a = self:currentAction()
  local pointsPerStep = a:pointsPerStep(self.pointsLeft)
  local hasEnoughPointsForStep = self.pointsLeft >= a:pointsPerStep(self.pointsLeft)

  if not hasEnoughPointsForStep then return end

  self.pointsLeft = self.pointsLeft - pointsPerStep
  -- TODO
  -- Thoughts: what if we just had a method on the action that returns tru e if it's done, irregardless of the actual points?

  a:step(dt)
end

--- Enqueues a new action. This method treats the queue as a FIFO.
function Component:enqueue(action)
  checkAction(action)
  table.insert(self.queue, action)
end

function Component:currentAction()
  local _, action = next(self.queue)
  return action
end

function Component:isFinished()
  if not self:hasAction() then return nil end
  return self:currentAction():isFinished()
end

local SampleAction = {
  pointsNeeded = function(_, available)
    assert(available)
    return 1
  end,
  pointsPerStep = function(_, available)
    assert(available)
    print("SampleAction.pointsPerStep()", available)
    return 1
  end,
  timePerStep = function()
    return 0.0
  end,
  step = function(_, dt)
    assert(dt)
    print("SampleAction.step()", dt)
  end,
  isFinished = function()
    print("SampleAction.isFinished()")
    return true
  end
}

local module = {}
module.System = System
module.Component = Component
module.SampleAction = SampleAction
return module
