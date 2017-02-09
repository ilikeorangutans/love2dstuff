
MainMenu = {}

function MainMenu:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.widgets = Widgets:new()
  o.widgets:add(Button:new({ x = 100, y = 30, w = 200, h = 60, label = "Map", onclick = function() o:openMapGeneratorView() end }))
  o.widgets:add(Button:new({ x = 100, y = 100, w = 200, h = 60, label = "game", onclick = function() xxx(o.viewport) end }))
  o.widgets:add(Button:new({ x = 100, y = 170, w = 200, h = 60, label = "Quit", onclick = function() love.event.quit() end }))
  return o
end

function MainMenu:resize(w, h)
  print("MainMenu:resize()", w, h)
end

function MainMenu:update(dt)
end

function MainMenu:mousemoved(x, y)
  self.widgets:mousemoved(x, y)
end

function MainMenu:keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    love.event.quit()
  end
end

function MainMenu:mousereleased(x, y, button, istouch)
  self.widgets:mousereleased(x, y, button, istouch)
end

function MainMenu:draw()
  self.widgets:draw()
end

function MainMenu:openMapGeneratorView()
  mapGenView = MapGeneratorView:new()
  self.viewstack:push(mapGenView)
  mapGenView:resize(800, 600)
end
