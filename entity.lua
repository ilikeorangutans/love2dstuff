local entity = {}

EntityManager = {
  lastID = 0,
  components = {},
  componentIDs = {},
  typeIndex = {},
}

function EntityManager:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--- Registers the given components under a new unique ID.
function EntityManager:create(comps)
  self.lastID = self.lastID + 1
  local id = self.lastID

  local types = {}
  for ctype, component in pairs(comps) do
    self:addType(ctype)
    self.components[ctype][id] = component
    table.insert(types, ctype)
  end

  local bitmask = self:typesToBitmask(types)
  self:addToTypeIndex(bitmask, id)
end

--- Returns a bitmask for the given component types.
function EntityManager:typesToBitmask(types)
  local bitmask = 0
  for _, t in ipairs(types) do
    local typeID = self:typeID(t)
    bitmask = bit.bor(bitmask, typeID)
  end

  return bitmask
end

--- Adds the given id with the given type bitmask to the index.
function EntityManager:addToTypeIndex(bitmask, id)
  self.typeIndex[id] = bitmask
end

--- Returns the type id for the given type.
function EntityManager:typeID(t)
  for i, v in ipairs(self.componentIDs) do
    if v == t then return 2^i end
  end
  assert(false, "Unknown type '" .. t .. "' when trying to find typeID!")
end

--- Registers a new component type and assigns it an id.
function EntityManager:addType(t)
  if self.components[t] then return end
  self.components[t] = {}
  table.insert(self.componentIDs, t)
end

--- Returns all components of the given type.
function EntityManager:getComponents(ctype)
  return self.components[ctype]
end

--- Returns all entity IDs that have at least the given component types.
function EntityManager:getIDsByType(...)
  local bitmask = self:typesToBitmask(...)

  local result = {}
  for id, b in ipairs(self.typeIndex) do
    if bit.band(bitmask, b) == bitmask then
      table.insert(result, id)
    end
  end

  return result
end

--- Returns all ids and components that match the given component types
function EntityManager:getComponentsByType(...)
  local ids = self:getIDsByType({...})

  local result = {}
  for _, id in ipairs(ids) do
    result[id] = {}
    for _, t in ipairs{...} do
      c = self.components[t][id]
      result[id][t] = c
    end
  end

  return result
end

return entity
