local margin = require('ui/margin')
local util = require('ui/utils')
local align = require('ui/alignment')

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
  o.alignment = o.alignment or align.Alignment:new(align.Horizontal.LEFT, align.Vertical.TOP)

  o.marginArea = { x=0, y=0, w=0, h=0 }
  o.widgetArea = { x=0, y=0, w=0, h=0 }

  o.layoutChanged = true
end

function Box:setMargin(t, r, b, l)
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
  self.alignment = align.Alignment:new(horizontal, vertical)
  self.layoutChanged = true

  return self
end

function Box:setBounds(x, y, w, h)
  local unchanged = self.bounds.x == x and self.bounds.y == y and self.bounds.w == w and self.bounds.h == h
  if unchanged then return end

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

  -- Within reduced area, place contents based on alignment:
  self.widgetArea = self.alignment:fill(self.marginArea, self.dimensions)

  self.layoutChanged = false
end

local module = {}
module.Model = Box
module.Vertical = Vertical
module.Horizontal = Horizontal
module.Alignment = Alignment
return module
