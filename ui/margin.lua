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

  box.x = box.x + self.left
  box.y = box.y + self.top
  box.w = box.w - box.x - box.x
  box.h = box.h - box.y - box.y

  return box
end

local module = {}
module.new = Margin.new
return module
