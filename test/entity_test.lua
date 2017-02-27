luaunit = require('luaunit')
require('entity')
require('bus')

TestEntityManager = {}

function TestEntityManager:setUp()
  self.bus = Bus:new()
  self.em = EntityManager:new({ bus=self.bus })
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

function TestEntityManager:testAddComponent()
  local id = self.em:create({foo={val='bar'}})

  self.em:addComponent(id, 'bar', {val='bar'})

  local entity = self.em:get(id)
  luaunit.assertEquals(entity, {foo={val='bar'}, bar={val='bar'}})

  local result = self.em:getComponentsByType('bar')
  luaunit.assertEquals(result, {{bar={val='bar'}}})
end

function TestEntityManager:testAddComponentFiresEvent()
  local fired = {}
  local id = self.em:create({foo={val='bar'}})
  self.bus:subscribe('entity.componentAdded', nil, function(_, event)
    fired = event
  end)

  self.em:addComponent(id, 'bar', {val='bar'})

  luaunit.assertEquals(fired, {id=id,ctype='bar',component={val='bar'}})
end

function TestEntityManager:testRemoveComponent()
  local id = self.em:create({foo={val='bar'},bar={val='bar'}})

  self.em:removeComponent(id, 'bar')

  local entity = self.em:get(id)
  luaunit.assertEquals(entity, {foo={val='bar'}})

  local result = self.em:getComponentsByType('bar')
  luaunit.assertEquals(result, {})
end

function TestEntityManager:testRemoveComponentFiresEvent()
  local fired = {}
  local id = self.em:create({foo={val='bar'},bar={val='bar'}})
  self.bus:subscribe('entity.componentRemoved', nil, function(_, event)
    fired = event
  end)

  self.em:removeComponent(id, 'bar')

  luaunit.assertEquals(fired, {id=id,ctype='bar',component={val='bar'}})
end


os.exit(luaunit.LuaUnit.run())

