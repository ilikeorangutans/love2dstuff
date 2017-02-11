local Margin = {}

function Margin:new(top, right, bottom, left)
  o = o or {}
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
  result.w = box.w - result.x - result.x
  result.h = box.h - result.y - result.y

  return result
end

local module = {}
module.new = function(top, right, bottom, left)
  return Margin:new(top, right, bottom, left)
end
module.Margin = Margin
return module
