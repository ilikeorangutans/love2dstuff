local ui = require('ui/widgets')

GameMapView = { }

function GameMapView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.game, "game needed")
  assert(o.map, "map needed")
  assert(o.tileset, "tileset needed")

  o.viewport = Viewport:new({
    screenx=0,
    screeny=0,
    tileW=o.tileset.tileW,
    tileH=o.tileset.tileH,
    mapWidth=o.map.width,
    mapHeight=o.map.height })

  o.menuBar = ui.HorizontalContainer:new():setAlignment('fill', 'top'):setDimensions(0, 0, 0, 33)
  o.menuBar:add(ui.Button:new({label="File", w=100, h=27}))
  o.menuBar:add(ui.Button:new({label="BAM", w=100, h=27}))

  --o.mapView = MapRenderer:new({ x=0, y=0, tileset=o.tileset, map=o.map, viewport=o.viewport, bus=o.bus })
  o.mapView = MapView:new({ tileset=o.tileset, map=o.map, viewport=o.viewport, bus=o.bus })
  o.mapView:setAlignment('fill', 'fill'):setDimensions(0, 0, 0, 0)

  o.sidebar = ui.VerticalContainer:new():setAlignment('fill', 'fill'):setDimensions(0, 0, 200, 0)

  o.ui = ui.VerticalContainer:new()
  o.ui:setAlignment('fill', 'fill')
  o.ui:add(o.menuBar)

  local h = o.ui:add(ui.HorizontalContainer:new())
  h:setAlignment('fill', 'fill'):setDimensions(0, 0, 0, 0)
  h:add(o.mapView)
  h:add(o.sidebar)

  return o
end

function GameMapView:subscribe(bus)
  bus:subscribe("selection.selected", self, GameMapView.onEntitySelected)
  bus:subscribe("selection.deselected", self, GameMapView.onEntityDeselected)
  bus:subscribe("map:hover_tile", self, GameMapView.onHoverTile)
end

function GameMapView:resize(w, h)
  print("GameMapView:resize()", w, h)
  self.ui:resize(w, h)
end

function GameMapView:update(dt)
  local deltax, deltay = 0, 0
  -- Note to self: using love.keyboard.isDown because keypressed (as used below)
  -- doesn't work quite with repeated keys for some reason.
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
  if deltax ~= 0 or deltay ~= 0 then
    self.viewport:moveBy(deltax, deltay)
  end
end

function GameMapView:mousemoved(x, y)
  self.ui:mousemoved(x, y)
  return
end

function GameMapView:keypressed(key, scancode, isrepeat)
  if scancode == 'escape' then
    -- TODO shouldn't just quit here, bring up menu or something
    love.event.quit()
  end
  if scancode == 'b' then
    -- TODO check return value?
    -- TODO should we just post an event if it can't be done?
    self.control:foundColony()
  end
  if scancode == 'c' then
    self:centerOnSelected()
  end
  if scancode == ',' then
    self.selectionManager:selectPrevIdle()
    self:centerOnSelected()
  end
  if scancode == '.' then
    self.selectionManager:selectNextIdle()
    self:centerOnSelected()
  end
  if scancode == 'return' then
    self:handleEndTurn()
  end
  if scancode == 'space' then
    self:doNothing()
  end
end

function GameMapView:mousereleased(x, y, button, istouch)
  local posx, posy = self.viewport:screenToMap(x, y)
  if button == 1 then
    -- TODO might run this through player control
    --self.bus:fire("viewport.clicked", {button=button, x=posx, y=posy})
  elseif button == 2 then
    if self.selected then
      local entity = self.selected

      local pos = entity.position
      local dx = math.abs(pos.x - posx)
      local dy = math.abs(pos.y - posy)
      local distance = math.sqrt((dx*dx) + (dy*dy))

      self.control:issueCommand(self.selectedID, {action='move', destination=posAt(posx, posy), path={length=distance}})
    end
  end
end

function GameMapView:draw()
  self.ui:layout()
  self.ui:draw()
end

function foo()
  local viewport = self.viewport
  viewport:draw()

  -- TODO global dependency on mousePosition
  local tile = mapView:getAt(mousePosition)
  local explored = mapView:isExplored(mousePosition)
  local tileMap = map:getAt(mousePosition)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', 600, 520, 200, 50)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(("Mouse: %d/%d"):format(mousePosition.x, mousePosition.y), 600, 520)
  love.graphics.print(("%s"):format(tile.terrain.title, explored), 600, 535)
  love.graphics.print(("Turn: %d Player: %s"):format(game.turn + 1, game:currentPlayer().name), 600, 550)
  if selectionManager.selected then
    local comps = entityManager:get(selectionManager.selected)
    if comps.action then
      local current = "-no orders-"
      if comps.action.current then
        current = comps.action.current.action
      end
      love.graphics.print(("%d/%d %s"):format(comps.action.points.left, comps.action.points.max, current), 600, 580)
    end

    local desc = ""
    if comps.colonist then
      desc = comps.colonist.profession.title
    end

    love.graphics.print(("[%d] %s, owner: %s"):format(selectionManager.selected, desc, comps.owner.id), 600, 565)
  end
end

function GameMapView:centerOnSelected()
  if not self.selected then return end
  if not self.selected.position then
    print("can't center on something without a position")
    return
  end

  self.viewport:center(self.selected.position)
end

function GameMapView:handleEndTurn()
  local predicate = function(comp)
    return comp.active and comp.points.left > 0
  end
  -- TODO game map view doesn't know about players... maybe that should
  -- live in the player control
  -- local entities = self.entityManager:getComponentsByType(ownedBy(self.player), {action=predicate}, position, selectable)

  -- for id, comps in pairs(entities) do
    -- self.selectionManager:select(id)
    -- self:centerOnSelected()
    -- if (#comps.action.queue) > 0 or comps.action.current then
      -- self.control:simulate(id)
      -- return
    -- else
      -- return
    -- end
  -- end

  self.control:endTurn()
end

function GameMapView:doNothing()
  if not self.selected then return end
  self.control:issueCommand(self.selectedID, {action='nothing'})
end

function GameMapView:onEntitySelected(e)
  self.selectedID = e.id
  self.selected = self.entityManager:get(e.id)
end

function GameMapView:onEntityDeselected(e)
  self.selectedID = nil
  self.selected = nil
end

function GameMapView:onHoverTile(e)
  local tile = self.map:getAt(e)
  print(tile.terrain.title)
end
