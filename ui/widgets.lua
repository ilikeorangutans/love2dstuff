
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

function Widgets:mousemoved(x, y)
  for _, widget in pairs(self.widgets) do
    if widget:mousemoved(x, y) then
      return true
    end
  end
end

function overBox(x, y, box)
  return over(x, y, box.x, box.y, box.x + box.w, box.y + box.h)
end

function over(x, y, tlx, tly, brx, bry)
  return tlx < x and x < brx and tly < y and y < bry
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

  o.state = 'out'

  return o
end

function Button:draw()
  local r, g, b = self:color()
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, 5, 5)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(self.label, self.x + 5, self.y + 5)
end

function Button:color()
  if self.state == 'over' then
    return 255, 255, 255
  else
    return 210, 210, 210
  end
end

function Button:mousereleased(x, y, button, istouch)
  if button == 1 and overBox(x, y, self) then
    self:onclick()
    return true
  end
end

function Button:mousemoved(x, y)
  if overBox(x, y, self) then
    self.state = 'over'
  else
    self.state = 'out'
  end
end

