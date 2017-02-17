luaunit = require('luaunit')
align = require('ui/alignment')
util = require('ui/utils')

function testAlignment()
  local a = align.Alignment:new('right', 'bottom')
  luaunit.assertEquals(a:fill(util.box(0, 0, 100, 100), util.box(0, 0, 50, 50)), util.box(50, 50, 50, 50))
end

os.exit(luaunit.LuaUnit.run())
