Tileset = {}

function Tileset:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Tileset:load()
  tilesetCoords = {}
  tilesetCoords['unexplored'] =         {x=0,y=0}
  tilesetCoords['deepocean'] =       {x=1,y=2}
  tilesetCoords['ocean'] =              {x=0,y=2}
  tilesetCoords['arctic'] =             {x=1,y=0}
  tilesetCoords['borealforest'] =       {x=2,y=0}
  tilesetCoords['broadleafforest'] =    {x=2,y=3}
  tilesetCoords['coniferforrest'] =     {x=0,y=1}
  tilesetCoords['desert'] =             {x=0,y=4}
  tilesetCoords['grassland'] =          {x=3,y=0}
  tilesetCoords['hills'] =              {x=2,y=4}
  tilesetCoords['marsh'] =              {x=3,y=3}
  tilesetCoords['mixedforest'] =        {x=0,y=3}
  tilesetCoords['mountains'] =          {x=3,y=4}
  tilesetCoords['plains'] =             {x=3,y=2}
  tilesetCoords['prairie'] =            {x=3,y=1}
  tilesetCoords['rainforest'] =         {x=1,y=1}
  tilesetCoords['savannah'] =           {x=1,y=3}
  tilesetCoords['scrubforest'] =        {x=1,y=4}
  tilesetCoords['swamp'] =              {x=3,y=3}
  tilesetCoords['tropicalforest'] =     {x=3,y=1}
  tilesetCoords['tundra'] =             {x=1,y=0}
  tilesetCoords['wetlandforest'] =      {x=3,y=1}
  tilesetCoords['ice'] =                {x=1,y=0}

  local terrain = love.graphics.newImage('assets/terrain.png')
  self.tileW, self.tileH = 32,32
  local tileW, tileH = self.tileW, self.tileH
  local tilesetW, tilesetH = terrain:getWidth(), terrain:getHeight()


  self.tiles = {}
  for t, pos in pairs(tilesetCoords) do
    local x = pos.x * self.tileW
    local y = pos.y * self.tileW
    self.tiles[t] = love.graphics.newQuad(x, y, tileW, tileH, tilesetW, tilesetH)
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
  local t = TerrainTypesByID[id]
  if not t or not t.handle then
    print("drawing id", id, "but no tile data found")
  end
  if not self.tiles[t.handle] then
    print("ERROR no tile found for handle", t.handle)
  end
  local quad = self.tiles[t.handle]
  assert(quad, ("no quad found for handle %q"):format(t.handle))
  love.graphics.draw(self.terrain, quad, x, y)
end

function Tileset:drawEntity(x, y, id)
  if not self.unit[id] then
    assert(false, ("Don't know how to draw entity  id %q"):format(id))
  end
  love.graphics.draw(self.units, self.unit[id], x, y, 0, 0.5, 0.5)
end

function Tileset:tileSize()
  return self.tileW, self.tileH
end
