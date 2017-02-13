local util = require('ui/utils')
local Margin = {}

function Margin:new(top, right, bottom, left)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.top = top
  o.right = right
  o.bottom = bottom
  o.left = left

  return o
end

function Margin:all()
  return { self.top, self.right, self.bottom, self.left }
end

function Margin:reduce(box)
  assert(box.x, "cannot reduce box without x")
  assert(box.y, "cannot reduce box without y")
  assert(box.w, "cannot reduce box without width")
  assert(box.h, "cannot reduce box without height")

  local result = {}
  result.x = box.x + self.left
  result.y = box.y + self.top
  result.w = box.w - self.left - self.right
  result.h = box.h - self.top - self.bottom

  return result
end

function Margin:__tostring()
  return ("%d %d %d %d"):format(self.top, self.right, self.bottom, self.right)
end

local module = {}
module.new = function(top, right, bottom, left)
  return Margin:new(top, right, bottom, left)
end
module.Margin = Margin
return module
