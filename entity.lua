local entity = {}

Entity = {
  components = {}
}

function Entity:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end




return entity
