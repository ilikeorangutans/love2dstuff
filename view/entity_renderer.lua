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
  assert(o.tileset, "tileset needed")

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
    local x, y = self.viewport:mapToScreen(e.position)

    if e.selectable.selected then
      self:drawSelectionBox(x, y)
    end
    self.tileset:drawEntity(x, y, e.drawable.img)
  end

  love.graphics.setScissor()
end

function EntityRenderer:drawSelectionBox(x, y)
  love.graphics.rectangle('line', x, y, self.viewport.tileWidth, self.viewport.tileHeight)
end

local module = {}
module.Renderer = EntityRenderer
return module
