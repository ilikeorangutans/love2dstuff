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
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 3, 1, 2, 3, 2, 2, 2, 2, 2},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 2, 1, 1, 3, 1, 1, 1, 1, 1},
    {1, 3, 1, 2, 3, 2, 2, 2, 2, 2},
  },
  width = 10,
  height = 10
}

function love.load()
  Tileset:load('countryside.png')
  local entityManager = EntityManager:new()

  mapView = MapView:new{map = Map, tileset = Tileset, entityManager = entityManager}
  mapView.screenx = 50
  mapView.screeny = 50
  mapView:resize(160, 100)

  position = {x = 3, y = 5}
  drawable = {img = 'caravel' }

  entityManager:create({ drawable = drawable, position = position})
end

function love.draw()
  mapView:draw()

  love.graphics.print("mouse over " .. tostring(posx) .. ", " .. tostring(posy), 0, 400)
end

function love.update(dt)
  local deltax, deltay = 0, 0

  if love.keyboard.isDown("a") then
    deltax = -2
  end
  if love.keyboard.isDown("d") then
    deltax = 2
  end
  if love.keyboard.isDown("w") then
    deltay = -2
  end
  if love.keyboard.isDown("s") then
    deltay = 2
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
  posx, posy = mapView:screenToMap(x, y)
end

