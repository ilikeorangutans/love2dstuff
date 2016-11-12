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

function PlayerControl:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.active = false
  return o
end

--- Ends the current turn.
function PlayerControl:endTurn()
  if not self.active then return end

  self.game:newTurn()
end

function PlayerControl:issueCommand(id, cmd)
  if not self.active then return end
  local comps = self.entityManager:get(id)
  if comps.owner.id ~= self.player.id then return end
  if not comps.action then return end

  comps.action:enqueue(cmd)
  comps.action:execute()
end

function PlayerControl:simulate(id)
  if not self.active then return end
  local comps = self.entityManager:get(id)
  assert(comps.owner, "player control cannot simulate comps without owner")
  if comps.owner.id ~= self.player.id then return end

  comps.action:execute()
end

--- Listens to newTurn events and marks the control active
function PlayerControl:onNewTurn(event)
  self.active = event.player == self.player
end
