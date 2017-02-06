pretty = require('pl.pretty')
local stringx = require 'pl.stringx'
stringx.import()

require 'util'
require 'viewstate'
require 'predicate'
require 'bus'
require 'tileset'
require 'viewport'
require 'entity'
require 'selection'
require 'terrain'
require 'map'
require 'player'
require 'game'
require 'ai'
require 'input'
require 'action'
require 'action_system'
require 'colony'
require 'colony_system'
require 'goods'
require 'building'
require 'colonist'
require 'professions'
require 'ship'
require 'view/game_map_view'
require 'view/colony_view'

function love.load()
  if love.system.getOS() == "Android" then
    love.window.setFullscreen(true)
  else
  end

  loadTerrainTypes()
  bus = Bus:new()

  game = Game:new(bus)
  local p1 = game:addPlayer(Player:new('Jakob'))
  local p2 = game:addPlayer(Player:new('Hannah'))

  tileset = Tileset:new()
  tileset:load()
  entityManager = EntityManager:new({bus=bus})
  map = Map:new()
  map:betterRandomize(50, 50)

  p1MapView = MapView:new({map=map,player=p1})
  p1MapView:subscribe(bus)
  p2MapView = MapView:new({map=map,player=p2})
  p2MapView:subscribe(bus)

  mapView = p1MapView

  selectionManager = SelectionManager:new({entityManager=entityManager,bus=bus,visibilityCheck=mapView,player=p1})
  selectionManager:subscribe(bus)

  --viewport = Viewport:new{map = mapView, tileset = tileset, entityManager = entityManager}
  --viewport:subscribe(bus)

  local drawable = {img = 'caravel'}
  local colony = {img = 'colony'}

  entityManager:create({ drawable=drawable, position={ x=10, y=10 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(10), visible={value=true}, vision={radius=10}, ship=Ship:new()})
  entityManager:create({ drawable=drawable, position={ x=20, y=20 }, selectable={selectable=true}, owner={ id=p2.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}, ship=Ship:new()})
  entityManager:create({ drawable={img = 'freecolonist'}, position={ x=2, y=1 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}, colonist=Colonist:new()})
  entityManager:create({ drawable={img = 'expertfarmer'}, position={ x=3, y=1 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}, colonist=Colonist:new({profession=Professions.expertfarmer})})
  entityManager:create({ drawable=drawable, position={ x=30, y=30 }, selectable={selectable=true}, owner={ id=p2.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}, ship=Ship:new()})
  entityManager:create({ drawable=drawable, position={ x=40, y=40 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}, ship=Ship:new()})

  mousePosition = {x=0, y=0}
  entityManager:create({position = mousePosition, cursor = {}})

  colonySystem = ColonySystem:new({ bus=bus, entityManager=entityManager, map=map })
  bus:subscribe('game.newTurn', colonySystem, colonySystem.onNewTurn)

  local actionHandlers = {
    found_colony = function(cmd, id)
      local entity = entityManager:get(id)
      local colonyID = colonySystem:foundColony(cmd.owner, entity.position, cmd.name)

      local colony = entityManager:get(colonyID)
      colonySystem:addColonist(colony, entity)
    end,
    move = function(cmd, id)
      local entity = entityManager:get(id)

      local dx = 0
      local dy = 0
      local pos = entity.position
      local dest = cmd.destination

      if pos.x > dest.x then
        dx = -1
      elseif pos.x < dest.x then
        dx = 1
      end
      if pos.y > dest.y then
        dy = -1
      elseif pos.y < dest.y then
        dy = 1
      end

      entity.position.x = entity.position.x + dx
      entity.position.y = entity.position.y + dy

      if pos.x == dest.x and pos.y == dest.y then
        entity.action:complete()
      end

      bus:fire('position.changed', {id=id, pos=entity.position, components=entity})
    end,
  }
  actionSystem = ActionSystem:new({ bus=bus, entityManager=entityManager, handlers=actionHandlers })
  bus:subscribe("game.newTurn", actionSystem, actionSystem.onNewTurn)

  p1Ctrl = PlayerControl:new({ entityManager=entityManager,game=game,player=p1 })
  p1Ctrl:subscribe(bus)
  p2Ctrl = PlayerControl:new({ entityManager=entityManager,game=game,player=p2 })
  p2Ctrl:subscribe(bus)

  ai = AI:new()
  ai.player = p2
  ai.control = p2Ctrl
  bus:subscribe('game.newTurn', ai, ai.onNewTurn)

  -- inputHandler = InputHandler:new({ bus=bus, entityManager=entityManager, selectionManager=selectionManager, viewport=viewport, player=p1, control=p1Ctrl })
  -- bus:subscribe("selection.selected", inputHandler, inputHandler.onSelected)
  -- bus:subscribe("selection.deselected", inputHandler, inputHandler.onDeselected)

  game:start()

  local gameMapView = GameMapView:new({ bus=bus, viewport=viewport, map=mapView, tileset=tileset, control=p1Ctrl, selectionManager=selectionManager, entityManager=entityManager })
  gameMapView:subscribe(bus)

  viewStack = ViewStack
  viewStack:push(gameMapView)

  local w, h, flags = love.window.getMode()
  viewStack:current():resize(w, h)

  viewStateHandler = ViewStateHandler
  bus:subscribe("selection.selected", viewStateHandler, ViewStateHandler.onSelectEntity)
end

ViewStateHandler = {}

function ViewStateHandler:onSelectEntity(e)
  local comps = entityManager:get(e.id)

  if comps.colony then
    local colonyView = ColonyView:new({ comps=comps, onExit=function() viewStack:pop() end })
    viewStack:push(colonyView)
  end
end

function love.resize(w, h)
  viewStack:current():resize(w, h)
end

function love.draw()
  viewStack:current():draw()
end

function love.update(dt)
  if love.keyboard.isDown("1") then
    mapView = p1MapView
  end
  if love.keyboard.isDown("2") then
    mapView = p2MapView
  end
  -- viewport.map = mapView

  ai:update(dt)
  actionSystem:update(dt)
  colonySystem:update(dt)

  viewStack:current():update(dt)
end

function love.keypressed(key, scancode, isrepeat)
  viewStack:current():keypressed(key, scancode, isrepeat)
end

function love.mousereleased(x, y, button, istouch)
  viewStack:current():mousereleased(x, y, button, istouch)
end

function love.mousemoved(x, y)
  viewStack:current():mousemoved(x, y)
end
