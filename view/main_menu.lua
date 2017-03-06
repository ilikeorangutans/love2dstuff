local ui = require('ui/widgets')
local util = require('ui/utils')
local map = require('map')
local ai = require('ai')

MainMenu = {}

function MainMenu:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.ui = ui.Panel:new({w=200, h=400})
  o.ui:setAlignment('center', 'top')
  o.ui:setMargin(11, 11, 11, 11)

  local c = o.ui:add(ui.VerticalContainer:new()):setAlignment('fill', 'fill'):setMargin(23, 23, 23, 23)

  l = c:add(ui.Label:new({ text = "Welcome to this fantastic little demonstration of my map generator" })):setAlignment('fill', 'fill'):setMargin(5, 5, 5, 5):setDimensions(0, 0, 0, 100)
  c:add(ui.Button:new({ w = 200, h = 31, label = "Map", onclick = function() o:openMapGeneratorView() end }))
  c:add(ui.Button:new({ w = 200, h = 31 + 11, label = "Start", onclick = function() o:openGameView() end })):setMargin(11, 0, 0, 0)
  c:add(ui.Button:new({ w = 200, h = 31 + 11, label = "Quit", onclick = function() love.event.quit() end })):setMargin(11, 0, 0, 0)

  l:setText("Welcome to this fantastic little demonstration of my map generator!!")

  return o
end

function MainMenu:resize(w, h)
  self.ui:resize(w, h)
end

function MainMenu:update(dt)
  self.ui:update(dt)
end

function MainMenu:mousemoved(x, y)
  self.ui:mousemoved(x, y)
end

function MainMenu:keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    love.event.quit()
  end
end

function MainMenu:mousereleased(x, y, button, istouch)
  self.ui:mousereleased(x, y, button, istouch)
end

function MainMenu:draw()
  self.ui:layout()
  self.ui:draw()
end

function MainMenu:openMapGeneratorView()
  local mapGenView = MapGeneratorView:new()
  self.viewstack:push(mapGenView)
  mapGenView:resize(800, 600)
end

function MainMenu:openGameView()
  local tileset = Tileset:new()
  tileset:load()

  local bus = Bus:new()
  local engine = Engine:new({bus=bus})
  engine:init()

  local game = Game:new({ bus=bus })
  local p1 = game:addPlayer(Player:new('Jakob'))
  local p2 = game:addPlayer(Player:new('Hannah'))
  local m = map.BetterRandomMapGenerator:generate(50, 50)


  local entityManager = engine.entityManager --EntityManager:new({ bus=bus })

  local p1ExplorableMap = map.ExplorableMap:new({map=m,player=p1}) -- wrap player, nationality, map view, etc into one object?
  p1ExplorableMap:subscribe(bus)
  local p2ExplorableMap = map.ExplorableMap:new({map=m,player=p2})
  p2ExplorableMap:subscribe(bus)

  entityManager:create({ drawable={img = 'caravel'}, position={ x=10, y=10 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(10), visible={value=true}, vision={radius=2}, ship=Ship:new()})
  entityManager:create({ drawable={img = 'caravel'}, position={ x=20, y=30 }, selectable={selectable=true}, owner={ id=p2.id }, action=ActionComponent:new(10), visible={value=true}, vision={radius=2}, ship=Ship:new()})
  entityManager:create({ drawable={img = 'expertfarmer'}, position={ x=3, y=1 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}, vision={radius=1}, colonist=Colonist:new({profession=Professions.expertfarmer})})

  local selectionManager = SelectionManager:new({entityManager=entityManager,bus=bus,visibilityCheck=p1ExplorableMap,player=p1}) -- ui concern?
  selectionManager:subscribe(bus)

  local p1Ctrl = PlayerControl:new({ map=p1ExplorableMap, entityManager=entityManager,game=game,player=p1 })
  p1Ctrl:subscribe(bus)
  local p2Ctrl = PlayerControl:new({ map=p2ExplorableMap, entityManager=entityManager,game=game,player=p2 })
  p2Ctrl:subscribe(bus)

  local ai = ai.DoNothingAI:new()
  ai.player = p2
  ai.control = p2Ctrl
  entityManager:create({ai=ai})


  local view = GameMapView:new({ bus=bus, game=game, control=p1Ctrl, engine=engine, map=p1ExplorableMap, tileset=tileset, selectionManager=selectionManager })
  view:subscribe(bus)
  game:start()
  self.viewstack:push(view)
end
