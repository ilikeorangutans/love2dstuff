local util = require('ui/utils')
local box = require('ui/boxmodel')
local margin = require('ui/margin')

local Widget = box.Model:new()

function Widget:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.margin = o.margin or box.Margin:new(0, 0, 0, 0)

  return o
end

function Widget:layout()
  self:recalculate()
end

function Widget:draw()
  print("Widget:draw()")
end

function Widget:update(dt)
end

function Widget:mousemoved(x, y)
  print("Widget:mousemoved()")
end

function Widget:mousepressed(x, y, button, istouch)
  print("Widget:mousepressed()")
end

function Widget:mousereleased(x, y, button, istouch)
  print("Widget:mousereleased()")
end

function Widget:resize(w, h)
  self.w = w
  self.h = h

  self:setBounds(self.bounds.x, self.bounds.y, w, h)
end

local Container = Widget:new()

function Container:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.widgets = {}

  return o
end

function Container:add(widget)
  table.insert(self.widgets, widget)
  return widget
end

function Container:resize(w, h)
  print("Container:resize()", w, h)
  self:setBounds(self.bounds.x, self.bounds.y, w, h)
  for _, widget in pairs(self.widgets) do
    widget:resize(w, h)
  end
end

function Container:layout()
  self:recalculate()
  for _, widget in pairs(self.widgets) do
    widget:layout()
  end
end

function Container:draw()
  for _, widget in pairs(self.widgets) do
    widget:draw()
  end
end

function Container:mousereleased(x, y, button, istouch)
  for _, widget in pairs(self.widgets) do
    if widget:mousereleased(x, y, button, istouch) then
      return true
    end
  end
end

function Container:mousemoved(x, y)
  for _, widget in pairs(self.widgets) do
    if widget:mousemoved(x, y) then
      return true
    end
  end
end

function Container:update(dt)
  for _, widget in pairs(self.widgets) do
    widget:update(dt)
  end
end

local Panel = Container:new()

function Panel:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.drawChildren = Container.draw
  o.color = o.color or { 0, 0, 80 }

  return o
end

function Panel:draw()
  love.graphics.setColor(self.color[1], self.color[2], self.color[3])
  love.graphics.rectangle('fill', self.marginArea.x, self.marginArea.y, self.marginArea.w, self.marginArea.h)
  self:drawChildren()
end

local VerticalContainer = Container:new()

function VerticalContainer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.x, "x needed")
  assert(o.y, "y needed")

  o.widgets = o.widgets or Widgets:new()

  o.w = 10
  o.h = 10

  return o
end

function VerticalContainer:resize(w, h)
  print("VerticalContainer:resize()", w, h)
  self:setBounds(self.bounds.x, self.bounds.y, w, h)
end

function VerticalContainer:layout()
  print("VerticalContainer:layout()", self.bounds.x, self.bounds.y)
  self:recalculate()

  local y = self.bounds.y
  for _, widget in pairs(self.widgets) do
    local x = self.bounds.x + self.margin.left
    y = y + self.margin.top

    widget:setBounds(x, y, widget.bounds.w, widget.bounds.h)

    y = y + self.margin.bottom + widget.bounds.h
  end
end

local Button = Widget:new()

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
  if button == 1 and util.overBox(x, y, self) then
    self:onclick()
    return true
  end
end

function Button:mousemoved(x, y)
  if util.overBox(x, y, self) then
    self.state = 'over'
  else
    self.state = 'out'
  end
end

local ui = {}

ui.Container = Container
ui.VerticalContainer = VerticalContainer
ui.Button = Button
ui.Panel = Panel
ui.Margin = margin.Margin

return ui
