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
  -- self.selectionManager = SelectionManager:new({entityManager=self.entityManager, bus=bus, })

  self.colonySystem = ColonySystem:new({ bus=self.bus, entityManager=self.entityManager, map=map })
end
