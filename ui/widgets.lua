local util = require('ui/utils')
local box = require('ui/boxmodel')
local margin = require('ui/margin')

local Widget = box.Model:new()

function Widget:new(o)
  print("> Widget:new()")
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function Widget:layout()
  self:recalculate()
end

function Widget:draw()

  if false then
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('line', self.bounds.x, self.bounds.y, self.bounds.w, self.bounds.h)
    love.graphics.setColor(0, 255, 0)
    love.graphics.rectangle('line', self.marginArea.x, self.marginArea.y, self.marginArea.w, self.marginArea.h)
    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle('line', self.widgetArea.x, self.widgetArea.y, self.widgetArea.w, self.widgetArea.h)
  end
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
  print("Widget:resize()", w, h)
  self:setBounds(self.bounds.x, self.bounds.y, w, h)
end

local Container = Widget:new()

function Container:new(o)
  print("> Container:new()")
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function Container:init()
  self.widgets = {}
end

function Container:add(widget)
  table.insert(self.widgets, widget)
  self.layoutChanged = true
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
  Widget.layout(self)
  for _, widget in pairs(self.widgets) do
    widget:layout()
  end
end

function Container:draw()
  Widget.draw(self)
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

local Panel = Widget:new()

function Panel:new(o)
  print("> Panel:new()")
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  Container.init(o)
  box.Model.init(o)

  o.color = o.color or { 0, 0, 80 }

  return o
end

function Panel:add(widget)
  self.child = widget
  self.layoutChanged = true
  return widget
end

function Panel:layout()
  Widget.layout(self)
  if self.child then
    self.child:setBounds(self.widgetArea.x, self.widgetArea.y, self.widgetArea.w, self.widgetArea.h)
    self.child:layout()
  end
end

function Panel:resize(w, h)
  print("Panel:resize()", w, h)
  Widget.resize(self, w, h)
  if self.child then self.child:resize(w, h) end
end

function Panel:draw()
  Widget.draw(self)
  love.graphics.setColor(self.color[1], self.color[2], self.color[3])
  love.graphics.rectangle('fill', self.widgetArea.x, self.widgetArea.y, self.widgetArea.w, self.widgetArea.h)

  if self.child then self.child:draw() end
end

local VerticalContainer = Container:new()

function VerticalContainer:new(o)
  print("> VerticalContainer:new()")
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  box.Model.init(o)
  Container.init(o)

  return o
end

function VerticalContainer:resize(w, h)
  print("VerticalContainer:resize()", w, h)
  Container.resize(self, w, h)
end

function VerticalContainer:layout()
  Widget.layout(self)
  --local children = #(self.widgets)
  -- print("VerticalContainer:layout() bounds:", util.box2string(self.bounds), "children:", children)

  local x = self.widgetArea.x
  local y = self.widgetArea.y
  for i, widget in pairs(self.widgets) do
    local w = self.widgetArea.w
    local h = self.widgetArea.h

    --print("VerticalContainer:layout() bounds for child: ", i, x, y, w, h)
    widget:setBounds(x, y, w, h)
    widget:layout()

    local effective = widget.widgetArea.h + widget.margin.top + widget.margin.bottom

    y = y + effective
  end
end

local Button = Widget:new()

function Button:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  box.Model.init(o)

  if not o.label then o.label = "Button" end
  if not o.onclick then o.onclick = function() print("clicked") end end

  o.dimensions = o.dimensions or { x=0, y=0, w=100, h=23 }
  print("Button:new() dimensions", o.dimensions.w, o.dimensions.h)
  o.state = 'out'

  return o
end

function Button:resize(w, h)
  print("Button:resize()", w, h)
  Widget.resize(self, w, h)
end

function Button:layout()
  --print("Button:layout()")
  Widget.layout(self)

  --print("Button:layout() done")
end

function Button:draw()
  Widget.draw(self)

  local r, g, b = self:color()
  local x = self.widgetArea.x
  local y = self.widgetArea.y
  local w = self.widgetArea.w
  local h = self.widgetArea.h

  --print("Button:draw()", x, y, w, h)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('fill', x, y, w, h, 5, 5)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(self.label, x + 5, y + 5)
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
  if util.overBox(x, y, self.widgetArea) then
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
