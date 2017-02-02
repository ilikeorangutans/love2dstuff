-- Detailed colony view
ColonyView = {}

function ColonyView:new(o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.comps.colony, "need colony for colony screen")
  o.colony = o.comps.colony

  o.viewport = Viewport:new({})

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
  --love.graphics.setColor(80, 80, 80)
  --love.graphics.rectangle('fill', 600, 520, 200, 50)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(("Colony: %q | Size: %d | Wares: %s"):format(self.colony.name, self.colony:size(), self.colony.warehouse:toString()), 0, 0)
end

