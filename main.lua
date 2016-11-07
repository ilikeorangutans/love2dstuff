require 'util'
require 'predicate'
require 'events'
require 'tileset'
require 'viewport'
require 'entity'
require 'selection'
require 'terrain'
require 'map'
require 'player'
require 'game'
require 'ai'
require 'input'
require 'action'
require 'action_system'
require 'colony'
require 'goods'

function love.load()
  bus = Bus:new()

  game = Game:new(bus)
  local p1 = game:addPlayer(Player:new('Jakob'))
  local p2 = game:addPlayer(Player:new('Hannah'))

  tileset = Tileset:new()
  tileset:load()
  entityManager = EntityManager:new({bus=bus})
  map = Map:new()
  map:randomize(60, 60)

  local p1MapView = MapView:new({map=map})

  selectionManager = SelectionManager
  selectionManager.entityManager = entityManager
  selectionManager.bus = bus
  bus:subscribe("viewport.clicked", selectionManager, selectionManager.onClick)
  bus:subscribe("entity.componentRemoved", selectionManager, selectionManager.onComponentRemoved)

  viewport = Viewport:new{map = p1MapView, tileset = tileset, entityManager = entityManager}
  bus:subscribe("viewport.scroll", viewport, viewport.onScroll)
  viewport.screenx = 0
  viewport.screeny = 0

  if love.system.getOS() == "Android" then
    love.window.setFullscreen(true)
  else
  end

  local w, h, flags = love.window.getMode()
  viewport:resize(w, h)

  local drawable = {img = 'caravel'}
  local colony = {img = 'colony'}

  entityManager:create({ drawable=drawable, position={ x=5, y=5 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}})
  entityManager:create({ drawable=drawable, position={ x=20, y=20 }, selectable={selectable=true}, owner={ id=p2.id }, action=ActionComponent:new(2), visible={value=true}})
  entityManager:create({ drawable=drawable, position={ x=30, y=30 }, selectable={selectable=true}, owner={ id=p2.id }, action=ActionComponent:new(2), visible={value=true}})
  entityManager:create({ drawable=drawable, position={ x=40, y=40 }, selectable={selectable=true}, owner={ id=p1.id }, action=ActionComponent:new(2), visible={value=true}})

  mousePosition = {x=0, y=0}
  entityManager:create({position = mousePosition, cursor = {}})

  colonySystem = ColonySystem:new({ bus=bus, entityManager=entityManager, map=map })
  bus:subscribe('game.newTurn', colonySystem, colonySystem.onNewTurn)

  colonySystem:foundColony(p1, {x=4,y=7}, "Jamestown")

  local actionHandlers = {
    build = function(cmd, id)
      local entity = entityManager:get(id)
      local colonyID = colonySystem:foundColony(cmd.owner, entity.position, cmd.name)

      local colony = entityManager:get(colonyID)
      colonySystem:addColonist(colony, entity)
    end,
    move = function(cmd, id)
    end,
  }
  actionSystem = ActionSystem:new({ entityManager=entityManager, handlers=actionHandlers })
  bus:subscribe("game.newTurn", actionSystem, actionSystem.onNewTurn)

  p1Ctrl = PlayerControl:new({ entityManager=entityManager,game=game,player=p1 })
  bus:subscribe('game.newTurn', p1Ctrl, p1Ctrl.onNewTurn)
  p2Ctrl = PlayerControl:new({ entityManager=entityManager,game=game,player=p2 })
  bus:subscribe('game.newTurn', p2Ctrl, p2Ctrl.onNewTurn)

  ai = AI:new()
  ai.player = p2
  ai.control = p2Ctrl
  bus:subscribe('game.newTurn', ai, ai.onNewTurn)

  inputHandler = InputHandler:new({ bus=bus, entityManager=entityManager, selectionManager=selectionManager, viewport=viewport, player=p1, control=p1Ctrl })
  bus:subscribe("selection.selected", inputHandler, inputHandler.onSelected)
  bus:subscribe("selection.deselected", inputHandler, inputHandler.onDeselected)

  game:start()
end

function love.resize(w, h)
  viewport:resize(w, h)
end

function love.draw()
  viewport:draw()

  local tile = map:getAt(mousePosition)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', 600, 550, 200, 50)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(("Mouse: %d/%d (%s)"):format(mousePosition.x, mousePosition.y, tile.terrain.title), 600, 550)
  love.graphics.print(("Turn: %d Player: %s"):format(game.turn + 1, game:currentPlayer().name), 600, 565)
  if selectionManager.selected then
    local comps = entityManager:get(selectionManager.selected)
    local points = ""
    if comps.action then
      points = ("%d ap"):format(comps.action.points.left)
    end

    love.graphics.print(("Selected: %d, owner: %s, %s"):format(selectionManager.selected, comps.owner.id, points), 600, 580)
  else
    love.graphics.print("", 600, 580)
  end
end

function love.update(dt)
  local deltax, deltay = 0, 0

  if love.keyboard.isDown("a") then
    deltax = -4
  end
  if love.keyboard.isDown("d") then
    deltax = 4
  end
  if love.keyboard.isDown("w") then
    deltay = -4
  end
  if love.keyboard.isDown("s") then
    deltay = 4
  end

  if deltax > 0 or deltax < 0 or deltay > 0 or deltay < 0 then
    bus:fire("viewport.scroll", {deltax=deltax, deltay=deltay})
  end

  ai:update(dt)
  actionSystem:update(dt)
  colonySystem:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
  inputHandler:keypressed(key, scancode, isrepeat)
end

function love.mousereleased(x, y, button, istouch)
  inputHandler:mousereleased(x, y, button, istouch)
end

function love.mousemoved(x, y)
  local posx, posy = viewport:screenToMap(x, y)
  mousePosition.x = posx
  mousePosition.y = posy
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end
