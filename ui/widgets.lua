
Widgets = {}
function Widgets:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.widgets = {}

  return o
end

function Widgets:add(widget)
  table.insert(self.widgets, widget)
end

function Widgets:draw()
  for _, widget in pairs(self.widgets) do
    widget:draw()
  end
end

function Widgets:mousereleased(x, y, button, istouch)
  for _, widget in pairs(self.widgets) do
    if widget:mousereleased(x, y, button, istouch) then
      return true
    end
  end
end

Button = {}
function Button:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  if not o.label then o.label = "Button" end
  if not o.onclick then o.onclick = function() print("clicked") end end
  if not o.x then o.x = 10 end
  if not o.y then o.y = 10 end
  if not o.w then o.w = 200 end
  if not o.h then o.h = 50 end

  return o
end

function Button:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, 5, 5)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(self.label, self.x + 5, self.y + 5)
end

function Button:mousereleased(x, y, button, istouch)
  if self.x < x and x < self.x + self.w and self.y < y and y < self.y + self.h then
    self:onclick()
  end
  return true
end

function Button:mousemoved(x, y)
end

