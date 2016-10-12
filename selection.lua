SelectionManager = {
  entityManager = {},
  bus = {}
}

function SelectionManager:onClick(event)
  if not (event.button == 1) then return end

  local entities = self.entityManager:getComponentsByType("selectable", {position=onPosition(event.x, event.y)})

  self:unselect()

  for id, comps in pairs(entities) do
    self:select(id)
  end
end

function SelectionManager:select(id)
  if self.selected == id then return end
  if self.selected then self:unselect() end
  local comps = self.entityManager:get(id)

  self.selected = id
  self.selectable = comps.selectable
  comps.selectable.selected = true

  self.bus:fire('selection.selected', {id=id})
end

function SelectionManager:unselect()
  if not self.selected then return end

  local id = self.selected
  self.selected = nil
  self.selectable.selected = false

  self.bus:fire('selection.unselected', {id=id})
end
