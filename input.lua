InputHandler = {}

function InputHandler:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.modifiers = {}

  return o
end

function InputHandler:mousemoved(x, y)
end

function InputHandler:mousereleased(x, y, button, istouch)
  local posx, posy = viewport:screenToMap(x, y)
  if button == 1 then
    -- TODO might run this through player control
    bus:fire("viewport.clicked", {button=button, x=posx, y=posy})
  elseif button == 2 then
    if self.selected then
      local entity = self.entityManager:get(self.selected)

      local pos = entity.position
      local dx = math.abs(pos.x - posx)
      local dy = math.abs(pos.y - posy)
      local distance = math.sqrt((dx*dx) + (dy*dy))

      self.control:issueCommand(self.selected, {action='move', destination=posAt(posx, posy), path={length=distance}})
    end
  end
end

function InputHandler:keyreleased(key, scancode)
  if scancode == 'lshift' or scancode == 'rshift'  then
    self.modifiers.shift = nil
  end
end

function InputHandler:keypressed(key, scancode, isrepeat)
  if scancode == 'lshift' or scancode == 'rshift'  then
    self.modifiers.shift = true
  end
  if scancode == 'escape' then
    love.event.quit()
  end
  if scancode == 'return' then
    self:handleEndTurn()
  end
  if scancode == 'space' then
    self:doNothing()
  end
  if scancode == 'c' then
    self:centerOnSelected()
  end
  if scancode == 'h' then
    local ent = self.entityManager:get(self.selected)
    ent.visible = not ent.visible
  end
  if scancode == 'b' then
    -- TODO check if we can actually build here
    -- TODO check if the given unit can build
    self.control:issueCommand(self.selected, {action='build', name="colony", owner=self.player})
  end
  if scancode == ',' then
    self.selectionManager:selectPrevIdle()
    self:centerOnSelected()
  end
  if scancode == '.' then
    self.selectionManager:selectNextIdle()
    self:centerOnSelected()
  end
end

function InputHandler:doNothing()
  if not self.selected then return end
  self.control:issueCommand(self.selected, {action='nothing'})
end

function InputHandler:handleEndTurn()
  local predicate = function(comp)
    return comp.active and comp.points.left > 0
  end
  local entities = self.entityManager:getComponentsByType(ownedBy(self.player), {action=predicate}, position, selectable)

  for id, comps in pairs(entities) do
    self.selectionManager:select(id)
    self:centerOnSelected()
    if (#comps.action.queue) > 0 or comps.action.current then
      self.control:simulate(id)
      return
    else
      return
    end
  end

  self.control:endTurn()
end

function InputHandler:centerOnSelected()
  if not self.selected then return end
  local entity = self.entityManager:get(self.selected)
  if not entity.position then
    print("can't center on something without a position")
    return
  end

  self.viewport:center(entity.position)
end

function InputHandler:onSelected(e)
  self.selected = e.id
end

function InputHandler:onDeselected(e)
  self.selected = nil
end
