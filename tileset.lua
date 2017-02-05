Tileset = {}

function Tileset:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Tileset:load()
  tilesetCoords = {}
  tilesetCoords['unexplored'] = {x=864,y=160}
  tilesetCoords['shippinglane'] = {x=160,y=448}
  tilesetCoords['ocean'] = {x=192,y=928}
  tilesetCoords['arctic'] = {x=64,y=800}
  tilesetCoords['borealforest'] = {x=288,y=896}
  tilesetCoords['broadleafforest'] = {x=288,y=896}
  tilesetCoords['coniferforrest'] = {x=288,y=896}
  tilesetCoords['desert'] = {x=288,y=896}
  tilesetCoords['grassland'] = {x=288,y=896}
  tilesetCoords['hills'] = {x=288,y=896}
  tilesetCoords['marsh'] = {x=288,y=896}
  tilesetCoords['mixedforest'] = {x=288,y=896}
  tilesetCoords['mountains'] = {x=288,y=896}
  tilesetCoords['plains'] = {x=288,y=896}
  tilesetCoords['prairie'] = {x=288,y=896}
  tilesetCoords['rainsforest'] = {x=288,y=896}
  tilesetCoords['savannah'] = {x=288,y=896}
  tilesetCoords['scrubforest'] = {x=288,y=896}
  tilesetCoords['swamp'] = {x=288,y=896}
  tilesetCoords['tropicalforest'] = {x=288,y=896}
  tilesetCoords['tundra'] = {x=288,y=896}
  tilesetCoords['wetlandforest'] = {x=288,y=896}

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
  self.unit['freecolonist'] = love.graphics.newQuad(13*60, 60, 60, 60, unitw, unith)
  self.unit['expertfarmer'] = love.graphics.newQuad(5*60, 0*60, 60, 60, unitw, unith)

  local cities = love.graphics.newImage("assets/cities.png")
  self.cities = cities
  local w, h = cities:getWidth(), cities:getHeight()
  self.unit['colony'] = love.graphics.newQuad(0, 0, 60, 60, w, h)
end

function Tileset:draw(x, y, id)
  print("drawing", id)
  local t = TerrainTypesByID[id]
  print("found", t)
  love.graphics.draw(self.terrain, self.tiles[t.terrain.id], x, y)
end

function Tileset:tileSize()
  return self.tileW, self.tileH
end
