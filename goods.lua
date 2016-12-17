local GoodsDefinitions = {
  corn = {
    id = 'corn',
    title = 'Corn',
    group = 'food',
    madeIn = 'outside',
  },
  fish = {
    id = 'fish',
    title = 'Fish',
    group = 'food',
    madeIn = 'outside',
  },
  tobacco = {
    id = 'tobacco',
    title = 'Tobacco',
    madeIn = 'outside',
  },
  sugar = {
    id = 'sugar',
    title = 'Sugar',
    madeIn = 'outside',
  },
  lumber = {
    id = 'lumber',
    title = 'Lumber',
    madeIn = 'outside',
  },
  furs = {
    id = 'furs',
    title = 'Furs',
    madeIn = 'outside',
  },
  rum = {
    id = 'rum',
    title = 'Rum',
    madeIn = 'building',
    madeFrom = 'sugar'
  },
  libertybells = {
    id = 'libertybells',
    title = 'Liberty Bells',
    madeIn = 'building',
  },
  crosses = {
    id = 'crosses',
    title = 'Crosses',
    madeIn = 'building',
  },
}

function loadGoodsDefinitions(input)
  local result = {}
  for _, definition in pairs(input) do
    result[definition.id] = definition
  end

  for _, goods in pairs(result) do
    if goods.madeFrom then
      local madeFrom = result[goods.madeFrom]
      assert(madeFrom, ("%q is made from unknown %q"):format(goods.id, goods.madeFrom))
      goods.madeFrom = madeFrom
    end
  end

  return result
end
Goods = loadGoodsDefinitions(GoodsDefinitions)

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

function Warehouse:get(t, amount)
  local result = math.min(amount, self:quantity(t))
  self:add(t, -result)
  return result
end

function Warehouse:toString()
	local goods = ""
	for t, amount in pairs(self.goods) do
    goods = goods .. ("%s: %d "):format(t, amount)
	end
  return ("Warehouse [%s]"):format(goods)
end
