bit = require('bit')

EntityManager = {}

function EntityManager:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.lastID = 0
  o.entities = {}
  o.components = {}
  o.componentIDs = {}
  o.typeIndex = {}
  return o
end

--- Registers the given components under a new unique ID.
function EntityManager:create(comps)
  self.lastID = self.lastID + 1
  local id = self.lastID
  self.entities[id] = comps

  local types = {}
  for ctype, component in pairs(comps) do
    self:addType(ctype)
    self.components[ctype][id] = component
    table.insert(types, ctype)
  end

  local bitmask = self:typesToBitmask(types)
  self:addToTypeIndex(bitmask, id)

  return id
end

function EntityManager:get(id)
  return self.entities[id]
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

--- Returns all ids and components that match all the given component types
-- @param p either strings or tables
function EntityManager:getComponentsByType(...)
  local types, predicates = extractTypesAndPredicates({...})
  local ids = self:getIDsByType(types)

  local result = {}
  for _, id in ipairs(ids) do
    local components = self:matchesAll(id, types, predicates)
    if components then
      result[id] = components
    end
  end
  return result
end

function EntityManager:matchesAll(id, types, predicates)
  local components = {}
  for _, t in ipairs(types) do
    local component = self.components[t][id]
    local predicate = predicates[t]

    if not matches(component, t, predicate) then return nil end

    components[t] = component
  end
  return components
end

function matches(component, t, predicate)
  if not predicate then return component end
  if predicate(component) then return component end
end

function extractTypesAndPredicates(input)
  local types = {}
  local predicates = {}

  for _, x in ipairs(input) do
    local t = type(x)
    if t == 'string' then
      table.insert(types, x)
    elseif t == 'table' then
      ctype, predicate = next(x)
      assert(type(predicate) == 'function', "predicate must be a function")
      table.insert(types, ctype)
      predicates[ctype] = predicate
    end
  end

  return types, predicates
end

function EntityManager:addComponent(id, ctype, component)
  self:addType(ctype)
  self.components[ctype][id] = component
  local typeID = self:typeID(ctype)
  local bitmask = self.typeIndex[id]
  bitmask = bit.bor(bitmask, typeID)
  self.typeIndex[id] = bitmask
  self.entities[id][ctype] = component
  self.bus:fire('entity.componentAdded', {id=id, ctype=ctype, component=component})
end

function EntityManager:removeComponent(id, ctype)
  local component = self.components[ctype][id]
  self.components[ctype][id] = nil
  self.entities[id][ctype] = nil
  local typeID = self:typeID(ctype)
  local bitmask = self.typeIndex[id]
  bitmask = bit.band(bitmask, bit.bnot(typeID))
  self.typeIndex[id] = bitmask
  self.bus:fire('entity.componentRemoved', {id=id, ctype=ctype, component=component})
end

