pretty = require('pl.pretty')
local stringx = require 'pl.stringx'
stringx.import()
local tablex = require 'pl.tablex'

require 'view/map_renderer'
require 'view/main_menu'
require 'view/map_generator_view'
require 'util'
require 'viewstate'
require 'predicate'
require 'bus'
require 'tileset'
require 'viewport'
require 'entity'
require 'selection'
require 'terrain'
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
require 'engine'
require 'view/game_map_view'
require 'view/colony_view'
require 'view/map_view'

function love.load()
  if love.system.getOS() == "Android" then
    love.window.setFullscreen(true)
  else
  end

  loadTerrainTypes()

  viewStack = ViewStack
  local w, h, flags = love.window.getMode()
  viewStack:resize(w, h)

  local mainMenu = MainMenu:new()
  viewStack:push(mainMenu)

  viewStateHandler = ViewStateHandler
end

function xxx(viewstack)
  bus = Bus:new()
  bus:subscribe("selection.selected", viewStateHandler, ViewStateHandler.onSelectEntity)
  game = Game:new({ bus=bus })
  local p1 = game:addPlayer(Player:new('Jakob'))
  local p2 = game:addPlayer(Player:new('Hannah'))

  local tileset = Tileset:new()
  tileset:load()
  entityManager = EntityManager:new({bus=bus})
  map = Map:new()
  map:betterRandomize(50, 50)

  p1ExplorableMap = ExplorableMap:new({map=map,player=p1})
  p1ExplorableMap:subscribe(bus)
  p2ExplorableMap = ExplorableMap:new({map=map,player=p2})
  p2ExplorableMap:subscribe(bus)

  mapView = p1ExplorableMap

  selectionManager = SelectionManager:new({entityManager=entityManager,bus=bus,visibilityCheck=mapView,player=p1})
  selectionManager:subscribe(bus)

  local drawable = {img = 'caravel'}
  local colony = {img = 'colony'}

  entityManager:create({ drawable=drawable, position={ x=10, y=10 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(10), visible={value=true}, vision={radius=10}, ship=Ship:new()})

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

  local gameMapView = GameMapView:new({ bus=bus, map=mapView, tileset=tileset, control=p1Ctrl, selectionManager=selectionManager, entityManager=entityManager })
  gameMapView:subscribe(bus)

  viewStack:push(gameMapView)
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
  viewStack:resize(w, h)
end

function love.draw()
  viewStack:current():draw()
end

function love.update(dt)
  --ai:update(dt)
  --actionSystem:update(dt)
  --colonySystem:update(dt)

  viewStack:current():update(dt)
end

function love.keypressed(key, scancode, isrepeat)
  viewStack:current():keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button, istouch)
  viewStack:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
  viewStack:current():mousereleased(x, y, button, istouch)
end

function love.mousemoved(x, y)
  viewStack:mousemoved(x, y)
end

