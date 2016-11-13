SelectionManager = {
  entityManager = {},
  bus = {}
}

function SelectionManager:onClick(event)
  if not (event.button == 1) then return end

  if not self.mapView:isVisible(event) then return end
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

function SelectionManager:select(id)
  if self.selected == id then return end
  if self.selected then self:unselect() end
  local comps = self.entityManager:get(id)

  self.selected = id
  self.selectable = comps.selectable
  comps.selectable.selected = true

  print("Selected entity:", id)
  for comp, v in pairs(comps) do
    print("   ", comp)
  end

  self.bus:fire('selection.selected', {id=id})
end

function SelectionManager:unselect()
  if not self.selected then return end

  local id = self.selected
  self.selected = nil
  self.selectable.selected = false

  self.bus:fire('selection.deselected', {id=id})
end

