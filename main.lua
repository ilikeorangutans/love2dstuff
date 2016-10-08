require 'events'
require 'tileset'
require 'viewport'
require 'entity'
require 'selection'
require 'map'
require 'player'

function love.load()
  bus = Bus:new()

  game = Game:new(bus)
  bus:subscribe('game.endTurn', game, game.onEndTurn)
  local p1 = game:addPlayer(Player:new('Jakob'))
  local p2 = game:addPlayer(Player:new('Hannah'))

  Tileset:load('assets/countryside.png')
  entityManager = EntityManager:new()

  map = Map:new()
  map:randomize(30, 30)

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

  entityManager:create({ drawable = drawable, position = {x = 5, y = 5}, selectable = {}, owner = { id = p1.id }})
  entityManager:create({ drawable = drawable, position = {x = 10, y = 11}, selectable = {}, owner = { id = p2.id }})

  mousePosition = {x=0, y=0}
  entityManager:create({position = mousePosition, cursor = {}})

  bus:subscribe('selection.selected', nil, function(_, event)
    print("Entity selected: ", event.id)
  end)
  bus:subscribe('selection.unselected', nil, function(_, event)
    print("Entity unselected: ", event.id)
  end)
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
    love.graphics.print(("Selected: %d, owner: %s"):format(selectionManager.selected, comps.owner.id), 600, 580)
  else
    love.graphics.print("Nothing selected", 600, 580)
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
end

function love.keypressed(key, scancode, isrepeat)
  if scancode == 'escape' then
    love.event.quit()
  end
  if scancode == 'return' then
    bus:fire("game.endTurn", nil)
  end
end

function love.mousereleased(x, y, button, istouch)
  local posx, posy = viewport:screenToMap(x, y)
  bus:fire("viewport.clicked", {button=button, x=posx, y=posy})
end

function love.mousemoved(x, y)
  local posx, posy = viewport:screenToMap(x, y)
  mousePosition.x = posx
  mousePosition.y = posy
end

function love.wheelmoved(x, y)
  viewport:moveBy(x, y)
end
