require 'util'
require 'predicate'
require 'events'
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
require 'goods'

function love.load()
  bus = Bus:new()

  game = Game:new(bus)
  local p1 = game:addPlayer(Player:new('Jakob'))
  local p2 = game:addPlayer(Player:new('Hannah'))

  tileset = Tileset:new()
  tileset:load()
  entityManager = EntityManager:new({bus=bus})
  map = Map:new()
  map:randomize(60, 60)

  p1MapView = MapView:new({map=map,player=p1})
  bus:subscribe('entity.created', p1MapView, p1MapView.onEntityCreated)
  bus:subscribe('entity.destroyed', p1MapView, p1MapView.onEntityDestroyed)
  p2MapView = MapView:new({map=map,player=p2})
  bus:subscribe('entity.created', p2MapView, p2MapView.onEntityCreated)
  bus:subscribe('entity.destroyed', p2MapView, p2MapView.onEntityDestroyed)

  mapView = p1MapView

  selectionManager = SelectionManager
  selectionManager.entityManager = entityManager
  selectionManager.bus = bus
  bus:subscribe("viewport.clicked", selectionManager, selectionManager.onClick)
  bus:subscribe("entity.componentRemoved", selectionManager, selectionManager.onComponentRemoved)

  viewport = Viewport:new{map = mapView, tileset = tileset, entityManager = entityManager}
  bus:subscribe("viewport.scroll", viewport, viewport.onScroll)
  viewport.screenx = 0
  viewport.screeny = 0

  if love.system.getOS() == "Android" then
    love.window.setFullscreen(true)
  else
  end

  local w, h, flags = love.window.getMode()
  viewport:resize(w, h)

  local drawable = {img = 'caravel'}
  local colony = {img = 'colony'}

  entityManager:create({ drawable=drawable, position={ x=1, y=1 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}})
  entityManager:create({ drawable=drawable, position={ x=20, y=20 }, selectable={selectable=true}, owner={ id=p2.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}})
  entityManager:create({ drawable=drawable, position={ x=30, y=30 }, selectable={selectable=true}, owner={ id=p2.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}})
  entityManager:create({ drawable=drawable, position={ x=40, y=40 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}})

  mousePosition = {x=0, y=0}
  entityManager:create({position = mousePosition, cursor = {}})

  colonySystem = ColonySystem:new({ bus=bus, entityManager=entityManager, map=map })
  bus:subscribe('game.newTurn', colonySystem, colonySystem.onNewTurn)

  colonySystem:foundColony(p1, {x=4,y=7}, "Jamestown")

  local actionHandlers = {
    build = function(cmd, id)
      local entity = entityManager:get(id)
      local colonyID = colonySystem:foundColony(cmd.owner, entity.position, cmd.name)

      local colony = entityManager:get(colonyID)
      colonySystem:addColonist(colony, entity)
    end,
    move = function(cmd, id)
    end,
  }
  actionSystem = ActionSystem:new({ entityManager=entityManager, handlers=actionHandlers })
  bus:subscribe("game.newTurn", actionSystem, actionSystem.onNewTurn)

  p1Ctrl = PlayerControl:new({ entityManager=entityManager,game=game,player=p1 })
  bus:subscribe('game.newTurn', p1Ctrl, p1Ctrl.onNewTurn)
  p2Ctrl = PlayerControl:new({ entityManager=entityManager,game=game,player=p2 })
  bus:subscribe('game.newTurn', p2Ctrl, p2Ctrl.onNewTurn)

  ai = AI:new()
  ai.player = p2
  ai.control = p2Ctrl
  bus:subscribe('game.newTurn', ai, ai.onNewTurn)

  inputHandler = InputHandler:new({ bus=bus, entityManager=entityManager, selectionManager=selectionManager, viewport=viewport, player=p1, control=p1Ctrl })
  bus:subscribe("selection.selected", inputHandler, inputHandler.onSelected)
  bus:subscribe("selection.deselected", inputHandler, inputHandler.onDeselected)

  game:start()
end

function love.resize(w, h)
  viewport:resize(w, h)
end

function love.draw()
  viewport:draw()

  local tile = mapView:getAt(mousePosition)
  local explored = mapView:isExplored(mousePosition)
  local tileMap = map:getAt(mousePosition)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', 600, 520, 200, 50)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(("Mouse: %d/%d"):format(mousePosition.x, mousePosition.y), 600, 520)
  love.graphics.print(("map  (%s)"):format(tileMap.terrain.title), 600, 535)
  love.graphics.print(("view (%s) (%s)"):format(tile.terrain.title, explored), 600, 550)
  love.graphics.print(("Turn: %d Player: %s"):format(game.turn + 1, game:currentPlayer().name), 600, 565)
  if selectionManager.selected then
    local comps = entityManager:get(selectionManager.selected)
    local points = ""
    if comps.action then
      points = ("%d ap"):format(comps.action.points.left)
    end

    love.graphics.print(("Selected: %d, owner: %s, %s"):format(selectionManager.selected, comps.owner.id, points), 600, 580)
  else
    love.graphics.print("", 600, 580)
  end
end

function love.update(dt)
  local deltax, deltay = 0, 0

  if love.keyboard.isDown("a") then
    deltax = -4
  end
  if love.keyboard.isDown("d") then
    deltax = 4
  end
  if love.keyboard.isDown("w") then
    deltay = -4
  end
  if love.keyboard.isDown("s") then
    deltay = 4
  end

  if love.keyboard.isDown("1") then
    mapView = p1MapView
  end
  if love.keyboard.isDown("2") then
    mapView = p2MapView
  end
  viewport.map = mapView

  if deltax > 0 or deltax < 0 or deltay > 0 or deltay < 0 then
    bus:fire("viewport.scroll", {deltax=deltax, deltay=deltay})
  end

  ai:update(dt)
  actionSystem:update(dt)
  colonySystem:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
  inputHandler:keypressed(key, scancode, isrepeat)
end

function love.mousereleased(x, y, button, istouch)
  inputHandler:mousereleased(x, y, button, istouch)
end

function love.mousemoved(x, y)
  local posx, posy = viewport:screenToMap(x, y)
  mousePosition.x = posx
  mousePosition.y = posy
end
