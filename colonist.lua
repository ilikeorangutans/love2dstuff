Colonist = {}

function Colonist:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  if not o.profession then
    o.profession = Professions.freecolonist
  end

  return o
end

--- Returns how much of the given goods the colonist can make.
function Colonist:produce(goods)
  local madeIn = goods.madeIn
  print("COLONIST", self.profession.title,"MAKING ", goods.title, " made in", madeIn)

  if self.profession.productivity.bonuses then
    for t, amount in pairs(self.profession.productivity.bonuses) do
      if Goods[t] == goods then
        return amount
      end
    end
  end

  return self.profession.productivity[madeIn]
end

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
