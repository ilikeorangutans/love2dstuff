Ship = {}

function Ship:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

function Ship:capabilities()
  local result = {}
  table.insert(result, "move")
  table.insert(result, "ship") -- TODO: it swims!
  return result
end
