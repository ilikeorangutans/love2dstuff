local ui = require('ui/widgets')
local util = require('ui/utils')

local EntityRenderer = ui.Widget:new()

function EntityRenderer:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.viewport, "viewport needed")
  assert(o.bus, "bus needed")
  assert(o.entityManager, "entity manager needed")
  assert(o.map, "map needed")

  ui.Widget.init(o)

  return o
end

function EntityRenderer:draw()
  love.graphics.setScissor(self.widgetArea.x, self.widgetArea.y, self.widgetArea.w, self.widgetArea.h)
  love.graphics.setColor(255, 255, 255, 255)

  local predicate = function(comp)
    return self.viewport:isVisible(comp) and self.map:isVisible(comp)
  end
  local entities = self.entityManager:getComponentsByType({position=predicate}, visible(), 'selectable', 'drawable')

  for i, e in ipairs(entities) do
    print("Rendering entity", i, "at", e.position.x, e.position.y)
  end
  --local area = self.map:getArea(posAt(v.startx, v.starty), posAt(v.endx, v.endy))
  --for pos, tile in area do
    --local x, y = self.viewport:mapToScreen(pos)
--
    --print("EntityRenderer:draw()", x, y)
  --end

  love.graphics.setScissor()
end

local module = {}
module.Renderer = EntityRenderer
return module
