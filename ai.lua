AI = {
  active = false
}

function AI:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function AI:onNewTurn(e)
  if not (self.player == e.player) then return end
  self.active = true
  self.time = 0
end

function AI:update(dt)
  if not self.active then return end
  self.time = self.time + dt

  if self.time > 0.5 then
    self.active = false
    self.control:endTurn()
  end
end


