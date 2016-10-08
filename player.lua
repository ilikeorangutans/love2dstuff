Player = {}

function Player:new(name)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.name = name

  return o
end

PlayerControl = {}

function PlayerControl:new(bus, game, player)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.bus = bus
  o.player = player
  o.game = game
  o.active = false
  return o
end

function PlayerControl:onNewTurn(event)
  if event.player == self.player then self.active = true end
  if not active then return end
  print("PlayerControl:onNewTurn()", event.player.id)

  self:endTurn()
end

function PlayerControl:endTurn()
  print("PlayerControl:endTurn()")

  self.game:newTurn()
end


