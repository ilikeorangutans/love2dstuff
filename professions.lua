Profession = {}
function Profession:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

Professions = {
  freecolonist = Profession:new({
    title="Free Colonist",
    productivity={
      outside=3,
      building=3,
      bonuses={},
    }
  }),
  expertfarmer = Profession:new({
    title="Expert Farmer",
    productivity={
      outside=3,
      building=3,
      bonuses={
        corn=5,
      },
    }
  }),
}
