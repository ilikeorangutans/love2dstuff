
Goods = {
  corn = {
    title = 'Corn',
  },
  fish = {
    title = 'Fish',
  },
  tobacco = {
    title = 'Tobacco',
  },
  sugar = {
    title = 'Sugar',
  },
  lumber = {
    title = 'Lumber',
  },
  tobacco = {
    title = 'Tobacco',
  },
  furs = {
    title = 'Furs',
  },
}

Warehouse = {}

function Warehouse:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.limit = 100
  o.goods = {}
  return o
end

function Warehouse:quantity(t)
  if not self.goods[t] then return 0 end
  return self.goods[t]
end

function Warehouse:add(t, amount)
  if not self.goods[t] then self.goods[t] = 0 end
  self.goods[t] = self.goods[t] + amount
end

function Warehouse:toString()
	local goods = ""
	for t, amount in pairs(self.goods) do
    goods = goods .. ("%s: %d "):format(t, amount)
	end
  return ("Warehouse: %s"):format(goods)
end
