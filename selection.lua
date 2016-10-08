SelectionManager = {
  entityManager = {},
  bus = {}
}

function SelectionManager:onClick(event)
  if not (event.button == 1) then return end

  local entities = self.entityManager:getComponentsByType("selectable", {position=onPosition(event.x, event.y)})

  self:unselect()

  for id, comps in pairs(entities) do
    self:select(id, comps.selectable)
  end
end

function SelectionManager:select(id, selectable)
  if self.selected == id then return end

  self.selected = id
  self.selectable = selectable
  selectable.selected = true

  self.bus:fire('selection.selected', {id=id})
end

function SelectionManager:unselect()
  if not self.selected then return end

  local id = self.selected
  self.selected = nil
  self.selectable.selected = false

  self.bus:fire('selection.unselected', {id=id})
end

function onPosition(x, y)
  return function(input)
    local result = x == input.x and y == input.y
    return result
  end
end
