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

function TestEntityManager:testCreateAssignsDifferentIDs()
  local a = self.em:create({foobar={foo="bar"}})
  local b = self.em:create({foobar={foo="blargh"}})

  luaunit.assertNotEquals(a, b)
end

function TestEntityManager:testGetComponentsByTypeReturnsOnlyIDsThatMatchAllPredicates()
  local a = self.em:create({foobar={foo="bar"}})
  local b = self.em:create({foobar={foo="blargh"}})

  local predicate = function(comp)
    return comp.foo == 'blargh'
  end

  local result = self.em:getComponentsByType({foobar=predicate})

  luaunit.assertIsTable(result)
  luaunit.assertEquals(result[2], {foobar={foo='blargh'}})
end

os.exit(luaunit.LuaUnit.run())

