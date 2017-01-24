-- Detailed colony view
ColonyView = {}

function ColonyView:new(comps)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.comps = comps

  return o
end

function ColonyView:draw()
  love.graphics.setColor(80, 80, 80)
  love.graphics.rectangle('fill', 600, 520, 200, 50)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("COLONY")
end

