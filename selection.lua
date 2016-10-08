SelectionManager = {
  entityManager = {},
}

function SelectionManager:onClick(event)
  local entities = self.entityManager:getComponentsByType("selectable", {position=onPosition(event.x, event.y)})

  self:unselect()

  for id, comps in ipairs(entities) do
    self:select(id)
  end
end

function SelectionManager:select(id)
  if self.selected == id then return end

  print("selecting")
  self.selected = id
end

function SelectionManager:unselect()
  if not self.selected then return end
  print("unselecting")
  self.selected = nil
  -- TODO fire event
end

function onPosition(x, y)
  return function(input)
    local result = x == input.x and y == input.y
    return result
  end
end
