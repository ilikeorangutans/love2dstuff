local ui = require('ui/widgets')
local map = require('map')
local maprenderer = require('view/map_renderer')

MapGeneratorView = {}

function MapGeneratorView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  local tileset = Tileset:new()
  tileset:load()

  local bus = Bus:new()
  local entityManager = EntityManager:new()

  o.pressed = {}
  o.mapWidth = 70
  o.mapHeight = 70
  o.ui = ui.VerticalContainer:new()
  o.ui:setAlignment('fill', 'fill')
  o.generator = map.PureRandomMapGenerator
  o.map = o.generator:generate(o.mapWidth, o.mapHeight)

  o.viewport = Viewport:new({
    bus=bus,
    screenx=0,
    screeny=0,
    tileW=tileset.tileW,
    tileH=tileset.tileH,
    mapWidth=o.map.width,
    mapHeight=o.map.height })

  o.mapView = maprenderer.MapRenderer:new({ bus=bus, x=0, y=0, tileset=tileset, map=o.map, viewport=o.viewport })
  o.ui:add(o.mapView)
  o.mapView:setAlignment('fill', 'fill')

  local p = o.ui:add(ui.Panel:new({h=50}))
  p:setAlignment('fill', 'fill')
  local c = p:add(ui.HorizontalContainer:new({h=35}))
  c:setAlignment('fill', 'fill')

  o.button = ui.Button:new({ label='pure random', w=100, h=23 })
  o.button:setMargin(5, 5, 0, 5)
  o.button.onclick = function()
    if o.button.label == 'pure random' then
      o.generator = map.BetterRandomMapGenerator
      o:randomizeMap(o.mapWidth, o.mapHeight)
      o.button.label = 'better'
    else
      o.button.label = 'pure random'
      o.generator = map.PureRandomMapGenerator
      o:randomizeMap(o.mapWidth, o.mapHeight)
    end
  end
  c:add(o.button)

  o.randomizeButton = ui.Button:new({label="randomize", w=100, h=23})
  o.randomizeButton:setMargin(5, 5, 0, 5)
  o.randomizeButton.onclick = function()
    o:randomizeMap(o.mapWidth, o.mapHeight)
  end
  c:add(o.randomizeButton)
  o.hoverLabel = c:add(ui.Label:new({ text="Hover over" }):setAlignment('fill', 'fill'):setMargin(3, 3, 3, 3))

  bus:subscribe("viewport:hover", o, MapGeneratorView.onHoverTile)

  return o
end

function MapGeneratorView:onHoverTile(e)
  local tile = self.map:getAt(e)
  self.hoverLabel:setText(("%d/%d: %s"):format(e.x, e.y, tile.terrain.title))
end

function MapGeneratorView:randomizeMap(w, h)
  local map = self.generator:generate(w, h)
  self.mapView.map = map
  self.map = map
end

function MapGeneratorView:resize(w, h)
  self.ui:resize(w, h)
end

function MapGeneratorView:update(dt)
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
  if deltax ~= 0 or deltay ~= 0 then
    self.viewport:moveBy(deltax, deltay)
  end
end

function MapGeneratorView:mousemoved(x, y)
  self.ui:mousemoved(x, y)
  self.viewport:mousemoved(x, y)

  if self.pressed[1] then
    local deltax = self.lastx - x
    local deltay = self.lasty - y
    self.viewport:moveBy(deltax, deltay)
  end

  self.lastx = x
  self.lasty = y
end

function MapGeneratorView:mousepressed(x, y, button, istouch)
  self.pressed[button] = true
  self.ui:mousepressed(x, y, button, istouch)
end

function MapGeneratorView:keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    self.viewstack:pop()
  end
end

function MapGeneratorView:mousereleased(x, y, button, istouch)
  self.pressed[button] = false
  if self.ui:mousereleased(x, y, button, istouch) then return end
end

function MapGeneratorView:draw()
  self.ui:layout()
  self.ui:draw()
end
