luaunit = require('luaunit')
require('bus')
require('game')
require('player')


function testCurrentPlayer()
  local bus = Bus:new()
  local game = Game:new({bus=bus})
  local a = game:addPlayer(Player:new('a'))
  local b = game:addPlayer(Player:new('b'))

  game:start()

  luaunit.assertEquals(game.turn, 1)
  luaunit.assertEquals(game:currentPlayer(), a)

  game:newTurn()
  luaunit.assertEquals(game.turn, 2)

  luaunit.assertEquals(game:currentPlayer(), b)

  game:newTurn()
  luaunit.assertEquals(game.turn, 3)
  luaunit.assertEquals(game:currentPlayer(), a)
end

os.exit(luaunit.LuaUnit.run())
