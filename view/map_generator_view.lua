MapGeneratorView = {}

function MapGeneratorView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  local tileset = Tileset:new()
  tileset:load()

  local entityManager = EntityManager:new()

  o.pressed = {}
  o.mapWidth = 70
  o.mapHeight = 70
  o.widgets = Widgets:new()
  o.generator = PureRandomMapGenerator
  o.map = o.generator:generate(o.mapWidth, o.mapHeight)

  o.mapView = MapRenderer:new({ x=0, y=0, w=10, h=10, tileset=tileset, map=o.map })
  o.widgets:add(o.mapView)

  o.button = Button:new({ label='pure random', w=100, h=23 })
  o.button.onclick = function()
    if o.button.label == 'pure random' then
      o.button.label = 'better'
      o.generator = BetterRandomMapGenerator
      o:randomizeMap(o.mapWidth, o.mapHeight)
    else
      o.button.label = 'pure random'
      o.generator = PureRandomMapGenerator
      o:randomizeMap(o.mapWidth, o.mapHeight)
    end
  end
  o.widgets:add(o.button)

  o.randomizeButton = Button:new({label="randomize", w=100, h=23, y = 38})
  o.randomizeButton.onclick = function()
    o:randomizeMap(o.mapWidth, o.mapHeight)
  end
  o.widgets:add(o.randomizeButton)

  return o
end

function MapGeneratorView:randomizeMap(w, h)
  self.mapView.map = self.generator:generate(w, h)
end

function MapGeneratorView:resize(w, h)
  self.mapView:resize(w, h)
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
    self.mapView.viewportArea:moveBy(deltax, deltay)
  end
end

function MapGeneratorView:mousemoved(x, y)
  self.widgets:mousemoved(x, y)

  if self.pressed[1] then
    local deltax = self.lastx - x
    local deltay = self.lasty - y
    self.mapView.viewportArea:moveBy(deltax, deltay)
  end

  self.lastx = x
  self.lasty = y
end

function MapGeneratorView:mousepressed(x, y, button, istouch)
  self.pressed[button] = true
end

function MapGeneratorView:keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    love.event.quit()
  end
end

function MapGeneratorView:mousereleased(x, y, button, istouch)
  self.pressed[button] = false
  if self.widgets:mousereleased(x, y, button, istouch) then return end
end

function MapGeneratorView:draw()
  self.widgets:draw()
end
