MapGeneratorView = {}

function MapGeneratorView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  local tileset = Tileset:new()
  tileset:load()

  local entityManager = EntityManager:new()

  o.widgets = Widgets:new()
  o.generator = PureRandomMapGenerator
  o.map = o.generator:generate(50, 50)

  o.mapView = MapRenderer:new({ x=10, y=10, w=10, h=10, tileset=tileset, map=o.map })
  o.widgets:add(o.mapView)

  o.button = Button:new({ label='pure random', w=100, h=23 })
  o.button.onclick = function()
    print("BANGO")
    if o.button.label == 'pure random' then
      o.button.label = 'better'
      o.generator = BetterRandomMapGenerator
      o:randomizeMap(50, 50)
    else
      o.button.label = 'pure random'
      o.generator = PureRandomMapGenerator
      o:randomizeMap(50, 50)
    end
  end
  o.widgets:add(o.button)

  o.randomizeButton = Button:new({label="randomize", w=100, h=23, y = 38})
  o.randomizeButton.onclick = function()
    print("BOOYA")
    o:randomizeMap(50, 50)
  end
  o.widgets:add(o.randomizeButton)

  return o
end

function MapGeneratorView:randomizeMap(w, h)
  print("randomizeMap()")
  self.mapView.map = self.generator:generate(w, h)
end

function MapGeneratorView:resize(w, h)
  self.mapView:resize(w-120, h-20)
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
end

function MapGeneratorView:keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    love.event.quit()
  end
end

function MapGeneratorView:mousereleased(x, y, button, istouch)
  self.widgets:mousereleased(x, y, button, istouch)
end

function MapGeneratorView:draw()
  self.widgets:draw()
end

function MapGeneratorView:openMapGeneratorView()
end
