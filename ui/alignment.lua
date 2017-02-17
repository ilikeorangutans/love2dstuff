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
  if self.horizontal == Horizontal.FILL and self.vertical == Vertical.FILL then
    local result = util.box(available.x, available.y, available.w, available.h)
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
  else
    assert(false, ("unknown horizontal alignment %q"):format(self.horizontal))
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
  else
    assert(false, ("unknown vertical alignment %q"):format(self.vertical))
  end

  local result = { x=x, y=y, w=w, h=h }
  return result
end

function Alignment:__tostring()
  return ("%s %s"):format(self.horizontal, self.vertical)
end

local module = {}

for _, horizontal in pairs(Horizontal) do
  for _, vertical in pairs(Vertical) do
    local name = ("%s_%s"):format(horizontal, vertical)
    module[name] = Alignment:new(horizontal, vertical)
  end
end

module.Alignment = Alignment
module.Horizontal = Horizontal
module.Vertical = Vertical
return module
