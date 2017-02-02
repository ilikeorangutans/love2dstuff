Colony = {}

function Colony:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.warehouse = Warehouse:new()
  o.worksites = {}
  o.colonists = {}
  o.buildings = {}

  return o
end

function Colony:size()
  return #(self.colonists)
end
