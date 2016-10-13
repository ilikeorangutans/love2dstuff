Tileset = {}

function Tileset:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Tileset:load(filename)
  local tileset = love.graphics.newImage(filename)

  self.tileW, self.tileH = 32,32
  local tileW, tileH = self.tileW, self.tileH
  local tilesetW, tilesetH = tileset:getWidth(), tileset:getHeight()

  self.tileset = tileset
  self.tiles = {}
  self.tiles[1] = love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH)
  self.tiles[2] = love.graphics.newQuad(tileW, 0, tileW, tileH, tilesetW, tilesetH)
  self.tiles[3] = love.graphics.newQuad(0, tileH, tileW, tileH, tilesetW, tilesetH)

  local units = love.graphics.newImage("assets/units.png")
  local unitw, unith = units:getWidth(), units:getHeight()

  self.units = units
  self.unit = {}
  self.unit['caravel'] = love.graphics.newQuad(3*60, 60, 60, 60, unitw, unith)

  local cities = love.graphics.newImage("assets/cities.png")
  self.cities = cities
  local w, h = cities:getWidth(), cities:getHeight()
  self.unit['colony'] = love.graphics.newQuad(0, 0, 60, 60, w, h)
end

function Tileset:draw(x, y, id)
  love.graphics.draw(self.tileset, self.tiles[id], x, y)
end

function Tileset:tileSize()
  return self.tileW, self.tileH
end
