InputHandler = {}

function InputHandler:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

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
      self.control:issueCommand(self.selected, {action='move', pos={x=posx, y=posy}})
    end
  end
end

function InputHandler:keypressed(key, scancode, isrepeat)
  if scancode == 'escape' then
    love.event.quit()
  end
  if scancode == 'return' then
    self.control:endTurn()
  end
end

function InputHandler:onSelected(e)
  self.selected = e.id
end

function InputHandler:onDeselected(e)
  self.selected = nil
end
