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

function Game:start()
  print("-- Game start")
  self:newTurn()
end

function Game:currentPlayer()
  local index = ((self.turn - 1) % (#self.players)) + 1
  return self.players[index]
end

function Game:addPlayer(player)
  table.insert(self.players, player)
  player.id = (#self.players)
  return player
end

function Game:newTurn()
  self.turn = self.turn + 1
  print("-- Game new turn:", self.turn, self:currentPlayer().name)
  self.bus:fire('game.newTurn', {player = self:currentPlayer()})
end

