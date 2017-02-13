local margin = require('ui/margin')
local util = require('ui/utils')

local Horizontal = {
  FILL = 'fill',
  LEFT = 'left',
  CENTER = 'center',
  RIGHT = 'right'
}
local Vertical = {
  FILL = 'fill',
  TOP = 'top',
  MIDDLE = 'middle',
  BOTTOM = 'bottom'
}

local Alignment = {}

function Alignment:new(horizontal, vertical)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.horizontal = horizontal
  o.vertical = vertical

  return o
end

function Alignment:fill(available, fill)
  print("Alignment:fill()", self)
  if self.horizontal == Horizontal.FILL and self.vertical == Vertical.FILL then
    local result = { x = available.x, y = available.y, w = available.w, h = available.h}
    return result
  end

  local x, y, w, h

  if self.horizontal == Horizontal.FILL then
    x = available.x
    w = available.w
  elseif self.horizontal == Horizontal.LEFT then
    x = available.x
    w = math.min(fill.w, available.w)
  elseif self.horizontal == Horizontal.CENTER then
    w = math.min(fill.w, available.w)
    x = available.x + ((available.w - w) / 2)
  elseif self.horizontal == Horizontal.RIGHT then
    w = math.min(fill.w, available.w)
    x = available.x + available.w - w
  end

  if self.vertical == Vertical.FILL then
    y = available.y
    h = available.h
  elseif self.vertical == Vertical.TOP then
    y = available.y
    h = math.min(fill.h, available.h)
  elseif self.vertical == Vertical.MIDDLE then
    h = math.min(fill.h, available.h)
    y = available.y + ((available.h - h) / 2)
  elseif self.vertical == Vertical.BOTTOM then
    h = math.min(fill.h, available.h)
    y = available.y + available.h - h
  end

  return { x=x, y=y, w=w, h=h }
end

function Alignment:__tostring()
  return ("%s %s"):format(self.horizontal, self.vertical)
end

local Box = {}

--- Box model
-- dimensions: desired size
-- bounds: designated size
--
-- Layout process:
-- 1) set bounds, i.e. area available
-- 2) calculate location based on margins and alignment
function Box:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Box:init()
  local o = self
  local d = {}
  d.x = o.x or 0
  d.y = o.y or 0
  d.w = o.w or 0
  d.h = o.h or 0
  o.dimensions = d

  o.bounds = { x=0, y=0, w=0, h=0}
  o.margin = o.margin or margin.new(0, 0, 0, 0)
  o.alignment = o.alignment or Alignment:new(Horizontal.LEFT, Vertical.TOP)

  o.marginArea = { x=0, y=0, w=0, h=0 }
  o.widgetArea = { x=0, y=0, w=0, h=0 }

  o.layoutChanged = true

  print(("Box:init() with dimensions: %s"):format(util.box2string(self.dimensions)))
end

function Box:setMargin(t, r, b, l)
  print(("Box:setMargin(%d, %d, %d, %d) on %s"):format(t, r, b, l, self))
  self.margin = margin.new(t, r, b, l)
  self.layoutChanged = true

  return self
end

function Box:setDimensions(x, y, w, h)
  local d = self.dimensions
  if x == d.x and y == d.y and w == d.w and h == d.h then return end

  d.x = x
  d.y = y
  d.w = w
  d.h = h
  self.layoutChanged = true

  return self
end

function Box:setAlignment(horizontal, vertical)
  self.alignment = Alignment:new(horizontal, vertical)
  self.layoutChanged = true

  return self
end

function Box:setBounds(x, y, w, h)
  --print("Box:setBounds()", x, y, w, h)
  if self.bounds.x == x and self.bounds.y == y and self.bounds.w == w and self.bounds.h == h then
    return
  end

  self.layoutChanged = true
  self.bounds.x = x
  self.bounds.y = y
  self.bounds.w = w
  self.bounds.h = h

  return self
end

function Box:recalculate()
  if not self.layoutChanged then return end

  -- Take bounds and reduce margins:
  self.marginArea = self.margin:reduce(self.bounds)
  print(("Box:recalculate() margin %d/%d/%d/%d"):format(self.margin.top, self.margin.right, self.margin.bottom, self.margin.left))
  print(("Box:recalculate() new margin area %dx%d at %d/%d"):format(self.marginArea.w, self.marginArea.h, self.marginArea.x, self.marginArea.y))

  -- Within reduced area, place contents based on alignment:
  self.widgetArea = self.alignment:fill(self.marginArea, self.dimensions)
  print(("Box:recalculate() new widget area %dx%d at %d/%d"):format(self.widgetArea.w, self.widgetArea.h, self.widgetArea.x, self.widgetArea.y))

  self.layoutChanged = false
end

local module = {}
module.Model = Box
module.Vertical = Vertical
module.Horizontal = Horizontal
module.Alignment = Alignment
return module
