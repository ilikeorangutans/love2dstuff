local margin = require('ui/margin')

local Box = {}

--- Box model
-- dimensions: desired size
-- bounds: designated size
function Box:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.dimensions = o.dimensions or { x=0, y=0, w=0, h=0 }
  o.bounds = { x=0, y=0, w=0, h=0}
  o.margin = o.margin or margin.new(0, 0, 0, 0)
  o.layoutChanged = false
  o.marginArea = { x=0, y=0, w=0, h=0 }

  return o
end

function Box:setBounds(x, y, w, h)
  print("Box:setBounds()", x, y, w, h)
  if self.bounds.x == x and self.bounds.y == y and self.bounds.w == w and self.bounds.h == h then
    return
  end

  self.layoutChanged = true
  self.bounds.x = x
  self.bounds.y = y
  self.bounds.w = w
  self.bounds.h = h
end

function Box:recalculate()
  if not self.layoutChanged then return end

  self.marginArea = self.margin:reduce(self.bounds)
  print(("Box:recalculate() margin %d/%d/%d/%d"):format(self.margin.top, self.margin.right, self.margin.bottom, self.margin.left))
  print(("Box:recalculate() new margin area %dx%d at %d/%d"):format(self.marginArea.w, self.marginArea.h, self.marginArea.x, self.marginArea.y))

  self.layoutChanged = false
end

local module = {}
module.Model = Box
return module
