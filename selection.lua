SelectionManager = {
  entityManager = {}
}

function SelectionManager:onClick(event)
  local entities = self.entityManager:getComponentsByType("selectable", "position")
  print("onClick got", table.getn(entities))
end
