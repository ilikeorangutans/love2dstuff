Map = {}

function Map:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.tiles = {}

  return o
end

function Map:randomize(w, h)
  self.width = w
  self.height = h

  for r=0, h-1 do
    self.tiles[r] = {}
    for c=0, w-1 do
      local x = math.random(3)
      self.tiles[r][c] = x
    end
  end
end
