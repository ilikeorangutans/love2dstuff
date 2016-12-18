local pretty = require 'pl.pretty'

SelectionManager = {}

function SelectionManager:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.bus, "SelectionManager requires bus")
  assert(o.entityManager, "SelectionManager requires entity manager")
  assert(o.visibilityCheck, "SelectionManager requires visiblity check")
  return o
end

function SelectionManager:subscribe(bus)
  bus:subscribe("viewport.clicked", self, SelectionManager.onClick)
  bus:subscribe("entity.componentRemoved", self, SelectionManager.onComponentRemoved)
end

function SelectionManager:onClick(event)
  if not (event.button == 1) then return end

  if not self.visibilityCheck:isVisible(event) then return end
  local entities = self.entityManager:getComponentsByType(selectable(), onPosition(event))

  self:unselect()

  for id, comps in pairs(entities) do
    self:select(id)
  end
end

function SelectionManager:onComponentRemoved(event)
  if event.ctype == 'selectable' and event.id == self.selected then
    self:unselect()
  end
end

function SelectionManager:selectNextIdle()
  if not self.selected then
    self:selectFirstIdle()
    return
  end

  local entities = self:playersIdleEntities()
  local last = nil
  for id, _ in pairs(entities) do
    if last == self.selected then
      self:select(id)
      return
    end
    last = id
  end

  self:selectFirstIdle()
end

function SelectionManager:selectPrevIdle()
  if not self.selected then
    self:selectFirstIdle()
    return
  end

  local entities = self:playersIdleEntities()
  local last = nil
  for id, _ in pairs(entities) do
    if self.selected == id and last then
      self:select(last)
      return
    end

    last = id
  end

  if last then self:select(last) end
end

function SelectionManager:selectFirstIdle()
  local entities = self:playersIdleEntities()
  local id, _ = next(entities)
  if id then self:select(id) end
end

function SelectionManager:playersIdleEntities()
  local entities = self.entityManager:getComponentsByType(ownedBy(self.player), selectable(), idleEntities())
  return entities
end

function SelectionManager:select(id)
  assert(id, "cannot select nil id")
  if self.selected == id then return end
  if self.selected then self:unselect() end
  local comps = self.entityManager:get(id)

  self.selected = id
  self.selectable = comps.selectable
  comps.selectable.selected = true

  local x = entityCapabilities(comps)
  caps = (", "):join(x)
  local components = {}

  print(("Selected entity: %d, capabilities: %s"):format(id, caps))
  for comp, v in pairs(comps) do
    table.insert(components, comp)
  end

  table.sort(components)
  print(" ", (", "):join(components))

  self.bus:fire('selection.selected', {id=id})
end


function canDo(comps)
  local result = {}

  for comp, v in pairs(comps) do
    if v.capabilities then
      local x = v.capabilities()
      union(result, x)
    end
  end

  return result
end

function SelectionManager:unselect()
  if not self.selected then return end

  local id = self.selected
  self.selected = nil
  self.selectable.selected = false

  self.bus:fire('selection.deselected', {id=id})
end

