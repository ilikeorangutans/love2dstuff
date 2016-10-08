require 'events'
require 'viewport'
require 'entity'
require 'selection'
require 'map'

posx, poxy = 0, 0

Tileset = { tileW, tileH }
function Tileset:load(filename)
  local tileset = love.graphics.newImage(filename)

  tileW, tileH = 32,32
  local tilesetW, tilesetH = tileset:getWidth(), tileset:getHeight()

  self['tileset'] = tileset
  self['tiles'] = {}
  self['tiles'][1] = love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH)
  self['tiles'][2] = love.graphics.newQuad(tileW, 0, tileW, tileH, tilesetW, tilesetH)
  self['tiles'][3] = love.graphics.newQuad(0, tileH, tileW, tileH, tilesetW, tilesetH)

  local units = love.graphics.newImage("assets/units.png")
  local unitw, unith = units:getWidth(), units:getHeight()

  self.units = units
  self.unit = {}
  self.unit['caravel'] = love.graphics.newQuad(3*60, 60, 60, 60, unitw, unith)
end

function Tileset:draw(x, y, id)
  love.graphics.draw(self['tileset'], self['tiles'][id], x, y)
end

function Tileset:tileSize()
  return tileW, tileH
end

function love.load()
  bus = Bus:new()

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

  entityManager:create({ drawable = drawable, position = {x = 5, y = 5}, selectable = {}})
  entityManager:create({ drawable = drawable, position = {x = 10, y = 11}, selectable = {}})

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
  if scancode == 'kp+' then
    viewport:resize(viewport.w + 2, viewport.h + 2)
  end
  if scancode == 'kp-' then
    viewport:resize(viewport.w - 2, viewport.h - 2)
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
