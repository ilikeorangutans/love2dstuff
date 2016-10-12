require 'predicate'
require 'events'
require 'tileset'
require 'viewport'
require 'entity'
require 'selection'
require 'map'
require 'player'
require 'game'
require 'ai'
require 'input'
require 'action'

function love.load()
  bus = Bus:new()

  game = Game:new(bus)
  local p1 = game:addPlayer(Player:new('Jakob'))
  local p2 = game:addPlayer(Player:new('Hannah'))

  Tileset:load('assets/countryside.png')
  entityManager = EntityManager:new()
  map = Map:new()
  map:randomize(60, 60)

  selectionManager = SelectionManager
  selectionManager.entityManager = entityManager
  selectionManager.bus = bus
  bus:subscribe("viewport.clicked", selectionManager, selectionManager.onClick)

  viewport = Viewport:new{map = map, tileset = Tileset, entityManager = entityManager}
  viewport.screenx = 0
  viewport.screeny = 0
  viewport:resize(800, 600)
  bus:subscribe("viewport.scroll", viewport, viewport.onScroll)

  local drawable = {img = 'caravel'}

  entityManager:create({ drawable=drawable, position={ x=5, y=5 }, selectable={}, owner={ id=p1.id }, action=ActionComponent:new(2)})
  entityManager:create({ drawable=drawable, position={ x=20, y=20 }, selectable={}, owner={ id=p2.id }, action=ActionComponent:new(2)})
  entityManager:create({ drawable=drawable, position={ x=30, y=30 }, selectable={}, owner={ id=p2.id }, action=ActionComponent:new(2)})
  entityManager:create({ drawable=drawable, position={ x=40, y=40 }, selectable={}, owner={ id=p1.id }, action=ActionComponent:new(2)})

  mousePosition = {x=0, y=0}
  entityManager:create({position = mousePosition, cursor = {}})


  actionSystem = ActionSystem:new({ entityManager=entityManager })
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

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', 600, 550, 200, 50)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(("Mouse: %d/%d"):format(mousePosition.x, mousePosition.y), 600, 550)
  love.graphics.print(("Turn: %d Player: %s"):format(game.turn + 1, game:currentPlayer().name), 600, 565)
  if selectionManager.selected then
    local comps = entityManager:get(selectionManager.selected)
    love.graphics.print(("Selected: %d, owner: %s, %d"):format(selectionManager.selected, comps.owner.id, comps.action.points.left), 600, 580)
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

  if deltax > 0 or deltax < 0 or deltay > 0 or deltay < 0 then
    bus:fire("viewport.scroll", {deltax=deltax, deltay=deltay})
  end

  ai:update(dt)
  actionSystem:update(dt)
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

