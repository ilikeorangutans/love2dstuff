Player = {}

function Player:new(name)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.name = name

  return o
end

--- Actions a player can take
-- Each instance controls access for a single player. Listens to events and
-- keeps track of who is the current player.
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

--- Ends the current turn.
function PlayerControl:endTurn()
  if not self.active then return end

  self.game:newTurn()
end

--- Listens to newTurn events and marks the control active
function PlayerControl:onNewTurn(event)
  self.active = event.player == self.player
end

