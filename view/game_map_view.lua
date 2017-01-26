-- map view of the colonies
GameMapView = {
  viewport = {},
  mapView = {}
}

function GameMapView:new(map, playerControl)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.map = map
  o.control = playerControl

  return o
end

function GameMapView:keypressed(key, scancode, isrepeat)
  if scancode == 'escape' then
    love.event.quit()
  end
  if scancode == 'b' then
    -- TODO check return value?
    -- TODO should we just post an event if it can't be done?
    self.control:foundColony()
  end
end

function GameMapView:draw()
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


