Tileset = {}

function Tileset:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Tileset:load(filename)
  local tileset = love.graphics.newImage(filename)
  print("Loaded tileset", tileset:getWidth(), tileset:getHeight())

  self.tileW, self.tileH = 32,32
  local tileW, tileH = self.tileW, self.tileH
  local tilesetW, tilesetH = tileset:getWidth(), tileset:getHeight()

  self.tileset = tileset
  self.tiles = {}
  self.tiles[1] = love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH)
  assert(self.tiles[1], "warbglbll")
  self.tiles[2] = love.graphics.newQuad(tileW, 0, tileW, tileH, tilesetW, tilesetH)
  self.tiles[3] = love.graphics.newQuad(0, tileH, tileW, tileH, tilesetW, tilesetH)

  local units = love.graphics.newImage("assets/units.png")
  print("Loaded units", units)
  local unitw, unith = units:getWidth(), units:getHeight()

  self.units = units
  self.unit = {}
  self.unit['caravel'] = love.graphics.newQuad(3*60, 60, 60, 60, unitw, unith)
end

function Tileset:draw(x, y, id)
  assert(id, "id must be provided")
  assert(self.tileset, "tileset must be loaded")
  assert(self.tiles, "tiles must be initialized")
  assert(self.tiles[id], ("specific tile must exist. id=%d"):format(id))
  love.graphics.draw(self.tileset, self.tiles[id], x, y)
end

function Tileset:tileSize()
  return self.tileW, self.tileH
end
