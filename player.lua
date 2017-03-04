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

  assert(o.map, "map required")
  assert(o.entityManager, "entity manager required")
  assert(o.game, "game required")
  assert(o.player, "player required")

  o.active = false
  o.selectedID = nil
  return o
end

function PlayerControl:subscribe(bus)
  bus:subscribe('game.newTurn', self, PlayerControl.onNewTurn)
  bus:subscribe('selection.selected', self, PlayerControl.onEntitySelected)
  bus:subscribe('selection.deselected', self, PlayerControl.onEntityDeselected)
end

function PlayerControl:onEntitySelected(e)
  self.selectedID = e.id
  self.selected = self.entityManager:get(e.id)
end

function PlayerControl:onEntityDeselected(e)
  self.selectedID = nil
  self.selected = nil
end

--- Ends the current turn.
function PlayerControl:endTurn()
  if not self.active then return end

  self.game:newTurn()
end

function PlayerControl:foundColony()
  if not self.selected then return end

  print("PlayerControl:foundColony()")
  local cmd = FoundColonyAction:new({map=self.map, entityManager=self.entityManager, id=self.selectedID})

  self.selected.action.active = true
  self.selected.action:enqueue(cmd)
  self.selected.action:execute()

  --self:issueCommand(self.selectedID, {action='found_colony', name="Colony", owner=self.player, map=self.map})
end

function PlayerControl:issueCommand(id, cmd)
  if not self.active then return end
  local selected = self.entityManager:get(id)
  if selected.owner.id ~= self.player.id then return end
  if not selected.action then return end
  if not entityCanDo(self.selected, cmd.action) then
    print(("Entity %d cannot perform %s"):format(self.selectedID, cmd.action))
    return
  end

  selected.action.active = true
  selected.action:enqueue(cmd)
  selected.action:execute()
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

