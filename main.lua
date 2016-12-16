require 'util'
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
  p1MapView:subscribe(bus)
  p2MapView = MapView:new({map=map,player=p2})
  p2MapView:subscribe(bus)

  mapView = p1MapView

  selectionManager = SelectionManager:new({entityManager=entityManager,bus=bus,visibilityCheck=mapView,player=p1})
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
  entityManager:create({ drawable={img = 'freecolonist'}, position={ x=2, y=1 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}, colonist=Colonist:new()})
  entityManager:create({ drawable={img = 'expertfarmer'}, position={ x=3, y=1 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}, colonist=Colonist:new({profession=Professions.expertfarmer})})
  entityManager:create({ drawable=drawable, position={ x=30, y=30 }, selectable={selectable=true}, owner={ id=p2.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}})
  entityManager:create({ drawable=drawable, position={ x=40, y=40 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}})

  mousePosition = {x=0, y=0}
  entityManager:create({position = mousePosition, cursor = {}})

  colonySystem = ColonySystem:new({ bus=bus, entityManager=entityManager, map=map })
  bus:subscribe('game.newTurn', colonySystem, colonySystem.onNewTurn)

  local actionHandlers = {
    build = function(cmd, id)
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
  love.graphics.print(("%s"):format(tile.terrain.title, explored), 600, 535)
  love.graphics.print(("Turn: %d Player: %s"):format(game.turn + 1, game:currentPlayer().name), 600, 550)
  if selectionManager.selected then
    local comps = entityManager:get(selectionManager.selected)
    if comps.action then
      local current = "-no orders-"
      if comps.action.current then
        current = comps.action.current.action
      end
      love.graphics.print(("%d/%d %s"):format(comps.action.points.left, comps.action.points.max, current), 600, 580)
    end

    local desc = ""
    if comps.colonist then
      desc = comps.colonist.profession.title
    end

    love.graphics.print(("[%d] %s, owner: %s"):format(selectionManager.selected, desc, comps.owner.id), 600, 565)
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

function love.keyreleased(key, scancode)
  inputHandler:keyreleased(key, scancode)
end

function love.mousereleased(x, y, button, istouch)
  inputHandler:mousereleased(x, y, button, istouch)
end

function love.mousemoved(x, y)
  local posx, posy = viewport:screenToMap(x, y)
  mousePosition.x = posx
  mousePosition.y = posy
end
