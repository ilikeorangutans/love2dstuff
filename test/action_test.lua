lu = require('luaunit')
action = require('xxx')
require('bus')
require('entity')

function testComponentInitialState()
  local c = action.Component:new({points=2})

  lu.assertEquals(c.queue, {})
  lu.assertEquals(c.points, 2)
  lu.assertEquals(c.pointsLeft, 2)
  lu.assertTrue(c:hasPointsLeft())
  lu.assertFalse(c:hasAction())
end

function testReplenish()
  local c = action.Component:new({points=2})
  c.pointsLeft = 0

  c:replenish()

  lu.assertEquals(c.pointsLeft, 2)
end

function testEnqueueActionChecksTheActionHasAllRequiredFields()
  local c = action.Component:new({points=2})
  local a = {'misses all the functions'}

  lu.assertError(c.enqueue, c, a)
  lu.assertFalse(c:hasAction())
end

function testSetActionSetsAction()
  local c = action.Component:new({points=2})
  c:setAction(action.SampleAction)

  lu.assertEquals(c:currentAction(), action.SampleAction)
end

function testCanStep()
  local c = action.Component:new({points=2})

  lu.assertFalse(c:canStep())

  c:setAction(action.SampleAction)
  lu.assertTrue(c:canStep())

  c.pointsLeft = 0

  c:setAction(action.SampleAction)
  lu.assertFalse(c:canStep())
end

function testStepConsumesPoints()
  local c = action.Component:new({points=2})
  c:setAction(action.SampleAction)

  c:step(0.0)

  lu.assertEquals(c.pointsLeft, 1)
end

function testSystemGetEntitiesToSimulate()
  local bus = Bus:new()
  local entityManager = EntityManager:new({bus=bus})
  local s = action.System:new({bus=bus, entityManager=entityManager})
  local c = action.Component:new({points=2})
  local id, comps = entityManager:create({action=c})

  -- Component without action shouldn't be picked up
  local result = s:getEntitiesToSimulate()
  lu.assertEquals(result, {})

  -- Component with action but not active shouldn't be picked up
  c:setAction(action.SampleAction)
  result = s:getEntitiesToSimulate()
  lu.assertEquals(result, {})

  -- Component with action but no points shouldn't be picked up
  c.pointsLeft = 0
  c.active = true
  result = s:getEntitiesToSimulate()
  lu.assertEquals(result, {})

  -- Component with action, points left, and active should be picked up
  c:replenish()
  result = s:getEntitiesToSimulate()
  local expected = {}
  expected[id] = comps
  lu.assertEquals(result, expected)
end

function testSystemFiresEventWhenActionIsDone()
  local bus = Bus:new()
  local entityManager = EntityManager:new({bus=bus})
  local s = action.System:new({bus=bus, entityManager=entityManager})
  local c = action.Component:new({points=2})
  local id, comps = entityManager:create({action=c})

  local called = false
  bus:subscribe('action:complete', nil, function() called = true end)

  c.active = true
  c:setAction(action.SampleAction)

  s:update(0.1)

  lu.assertTrue(called)
end

os.exit(lu.run())
