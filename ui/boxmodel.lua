local margin = require('ui/margin')

local Box = {}

function Box:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.dimensions = o.dimensions or { x=0, y=0, w=0, h=0 }
  o.bounds = { x=0, y=0, w=0, h=0}

  return o
end

local module = {}
module.Model = Box
module.Margin = Margin
return module
