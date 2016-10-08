luaunit = require('luaunit')
require('entity')

TestEntityManager = {}

function TestEntityManager:setUp()
  self.em = EntityManager:new()
end

function TestEntityManager:testGetComponentsByTypeWorksWithStrings()
  self.em:create({foobar={foo='bar'}})
  local result = self.em:getComponentsByType("foobar")

  luaunit.assertItemsEquals(result, {{foobar={foo='bar'}}})
end

function TestEntityManager:testGetComponentsByTypeWorksWithStringsAndPredicates()
end

function TestEntityManager:testGetComponentsByTypeReturnsOnlyIDsThatMatchAllPredicates()
  local a = self.em:create({foobar={foo="bar"}})
  luaunit.assertEquals(a, 1)
  local b = self.em:create({foobar={foo="blargh"}})

  local predicate = function(comp)
    return comp.foo == 'bar'
  end

  local result = self.em:getComponentsByType({foobar=predicate})

  luaunit.assertIsTable(result)
  luaunit.assertEquals(result[1], {foobar={foo='bar'}})
  luaunit.assertEquals(#result, 1)
end

os.exit(luaunit.LuaUnit.run())

