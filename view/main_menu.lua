local ui = require('ui/widgets')

MainMenu = {}

function MainMenu:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.ui = ui.Panel:new()
  o.ui.margin = ui.Margin:new(11, 13, 23, 17)
  --o.ui = ui.VerticalContainer:new({ x = 100, y = 0 })
  --
  local container = ui.VerticalContainer:new({ x = 100, y = 0 })

  --container:add(ui.Button:new({ w = 200, h = 60, label = "Map", onclick = function() o:openMapGeneratorView() end }))
  --container:add(ui.Button:new({ w = 200, h = 60, label = "game", onclick = function() o:openGameView() end }))
  container:add(ui.Button:new({ w = 200, h = 60, label = "Quit", onclick = function() love.event.quit() end }))

  --o.ui:add(container)
  return o
end

function MainMenu:resize(w, h)
  print("MainMen:resize()", w, h)
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
  local bus = Bus:new()
  local game = Game:new({ bus=bus })
  local p1 = game:addPlayer(Player:new('Jakob'))
  local p2 = game:addPlayer(Player:new('Hannah'))

  local map = BetterRandomMapGenerator:generate(50, 50)
  local tileset = Tileset:new()
  tileset:load()

  local entityManager = EntityManager:new({ bus=bus })
  entityManager:create({ drawable={img = 'caravel'}, position={ x=10, y=10 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(10), visible={value=true}, vision={radius=10}, ship=Ship:new()})

  local p1MapView = MapView:new({map=map,player=p1})
  p1MapView:subscribe(bus)
  local p2MapView = MapView:new({map=map,player=p2})
  p2MapView:subscribe(bus)

  local selectionManager = SelectionManager:new({entityManager=entityManager,bus=bus,visibilityCheck=p1MapView,player=p1})
  selectionManager:subscribe(bus)

  local colonySystem = ColonySystem:new({ bus=bus, entityManager=entityManager, map=map })
  bus:subscribe('game.newTurn', colonySystem, colonySystem.onNewTurn)

  local actionSystem = ActionSystem:new({ bus=bus, entityManager=entityManager, handlers=actionHandlers })
  local p1Ctrl = PlayerControl:new({ entityManager=entityManager,game=game,player=p1 })
  p1Ctrl:subscribe(bus)
  local p2Ctrl = PlayerControl:new({ entityManager=entityManager,game=game,player=p2 })
  p2Ctrl:subscribe(bus)
  bus:subscribe("game.newTurn", actionSystem, actionSystem.onNewTurn)

  local ai = AI:new()
  ai.player = p2
  ai.control = p2Ctrl
  bus:subscribe('game.newTurn', ai, ai.onNewTurn)

  local view = GameMapView:new({ game=game, map=p1MapView, tileset=tileset, selectionManager=selectionManager })
  view:subscribe(bus)
  self.viewstack:push(view)
end
