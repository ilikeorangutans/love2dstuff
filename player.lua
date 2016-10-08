Player = {}

function Player:new(name)
  o = {}
  setmetatable(o, self)
  self.__index = self

  o.name = name

  return o
end

Game = {}

function Game:new(bus)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.players = {}
  o.bus = bus
  o.turn = 0
  return o
end

function Game:addPlayer(player)
  table.insert(self.players, player)
  player.id = (#self.players)
  return player
end

function Game:currentPlayer()
  return self.players[self.turn % (#self.players) + 1]
end

function Game:endTurn()
  self.turn = self.turn + 1
  self.bus:fire('game.newTurn', {player = self:currentPlayer()})
end

function Game:onEndTurn(e)
  self:endTurn()
end
