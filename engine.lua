local ai = require('ai')
Engine = {}

function Engine:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.bus, "bus needed")

  return o
end

function Engine:init()
  self.entityManager = EntityManager:new({bus=self.bus})
  self.colonySystem = ColonySystem:new({ bus=self.bus, entityManager=self.entityManager })
  self.colonySystem:subscribe(self.bus)
  self.actionSystem = ActionSystem:new({ bus=bus, entityManager=self.entityManager, handlers=actionHandlers })
  self.actionSystem:subscribe(self.bus)

  self.aiSystem = ai.System:new({entityManager=self.entityManager})
  self.aiSystem:subscribe(self.bus)
end

function Engine:update(dt)
  self.colonySystem:update(dt)
  self.aiSystem:update(dt)
  self.actionSystem:update(dt)
end
