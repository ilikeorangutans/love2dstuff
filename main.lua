require 'mapview'
require 'entity'

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

  local units = love.graphics.newImage("units.png")
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

Map = {
  tiles = {
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2, 3, 1, 2, 3, 2, 2, 2, 2, 2},
  },
  width = 28,
  height = 30
}

function love.load()
  Tileset:load('countryside.png')
  local entityManager = EntityManager:new()

  mapView = MapView:new{map = Map, tileset = Tileset, entityManager = entityManager}
  mapView.screenx = 0
  mapView.screeny = 0
  mapView:resize(800, 600)

  position = {x = 3, y = 5}
  drawable = {img = 'caravel'}
  selectable = {selected = false}

  entityManager:create({ drawable = drawable, position = position, selectable = selectable})

  mousePosition = {x=0, y=0}
  entityManager:create({position = mousePosition, cursor = {}})
end

function love.draw()
  mapView:draw()
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

  mapView:moveBy(deltax, deltay)
end

function love.keypressed(key, scancode, isrepeat)
  if scancode == 'escape' then
    love.event.quit()
  end
  if scancode == 'kp+' then
    mapView:resize(mapView.w + 2, mapView.h + 2)
  end
  if scancode == 'kp-' then
    mapView:resize(mapView.w - 2, mapView.h - 2)
  end

end

function love.mousemoved(x, y)
  local posx, posy = mapView:screenToMap(x, y)
  mousePosition.x = posx
  mousePosition.y = posy
end

function love.wheelmoved(x, y)
  mapView:moveBy(x, y)
end
