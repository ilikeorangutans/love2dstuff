local AI = {
  active = false
}

function AI:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.time = 0

  return o
end

function AI:update(dt)
  self.time = self.time + dt

  if self.time > 0.5 then
    self.time = 0
    self.control:endTurn()
  end
end

local System = {}
function System:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function System:subscribe(bus)
  bus:subscribe('game.newTurn', self, System.onNewTurn)
end

function System:onNewTurn(event)
  print("ai.System:onNewTurn()")
  self.player = event.player
end

function System:update(dt)
  local predicate = {
    ai = function(comp)
      return comp.player == self.player
    end
  }
  local entities = self.entityManager:getComponentsByType(predicate)
  for id, entity in pairs(entities) do
    entity.ai:update(dt)
  end
end

local module = {}
module.DoNothingAI = AI
module.System = System
return module
