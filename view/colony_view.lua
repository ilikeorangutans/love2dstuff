-- Detailed colony view
ColonyView = {}

function ColonyView:new(comps, onExit)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.comps = comps
  o.onExit = onExit

  return o
end

function ColonyView:resize(w, h)
end

function ColonyView:update(dt)
end

function ColonyView:keypressed(key, scancode, isrepeat)
  if scancode == 'escape' then
    self.onExit()
  end
end

function ColonyView:draw()
  love.graphics.setColor(80, 80, 80)
  love.graphics.rectangle('fill', 600, 520, 200, 50)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("COLONY", 100, 100)
end

