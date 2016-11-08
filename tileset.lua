Tileset = {}

function Tileset:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Tileset:load()
  tilesetCoords = {}
  tilesetCoords[0] = {x=864,y=160}
  tilesetCoords[1] = {x=160,y=448}
  tilesetCoords[2] = {x=192,y=928}
  tilesetCoords[3] = {x=64,y=800}
  tilesetCoords[4] = {x=288,y=896}

  local terrain = love.graphics.newImage('assets/terrain_atlas.png')
  self.tileW, self.tileH = 32,32
  local tileW, tileH = self.tileW, self.tileH
  local tilesetW, tilesetH = terrain:getWidth(), terrain:getHeight()


  self.tiles = {}
  for t, pos in pairs(tilesetCoords) do
    self.tiles[t] = love.graphics.newQuad(pos.x, pos.y, tileW, tileH, tilesetW, tilesetH)
  end
  self.terrain = terrain

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
  love.graphics.draw(self.terrain, self.tiles[id], x, y)
end

function Tileset:tileSize()
  return self.tileW, self.tileH
end
