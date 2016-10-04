require 'mapview'

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
end

function Tileset:draw(x, y, id)
  love.graphics.draw(self['tileset'], self['tiles'][id], x, y)
end

function Tileset:tileSize()
  return tileW, tileH
end

Map = {
  tiles = {
    {1, 2, 1, 1, 3, 1, 1},
    {1, 2, 1, 1, 3, 1, 1},
    {1, 2, 1, 1, 3, 1, 1},
    {1, 2, 1, 1, 3, 1, 1},
    {1, 3, 1, 2, 3, 1, 1},
    {1, 2, 1, 1, 3, 1, 1},
    {1, 2, 1, 1, 3, 1, 1},
  }
}

Viewport = {
  width = 150,
  height = 100,
  x = 50,
  y = 50
}

function love.load()
  Tileset:load('countryside.png')
  mapView = MapView:new{map = Map, tileset = Tileset}
  mapView:resize(150, 100)
end

function love.draw()
    mapView:draw(Viewport)
    love.graphics.rectangle("line",  Viewport.x, Viewport.y, Viewport.width, Viewport.height)
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
  if scancode == '+' then
    mapView.resize(mapView.w + 2, mapView.h + 2)
  end

end
