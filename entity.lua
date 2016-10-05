local entity = {}

EntityManager = {
  lastID = 0,
  components = {}
}

function EntityManager:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function EntityManager:create(comps)
  self.lastID = self.lastID + 1
  local id = self.lastID

  for ctype, component in pairs(comps) do
    if not self.components[ctype] then self.components[ctype] = {} end
    self.components[ctype][id] = component
  end
end

function EntityManager:getByType(ctype)
  return self.components[ctype]
end

return entity
