-- Instructions

-- Check if you have LPeg properly installed in your machine by redoing some
-- examples from the previous lecture

lpeg = require "lpeg"
lu   = require "luaunit"

function testPattern ()
  local pattern = lpeg.P("teste")

  lu.assertEquals(pattern:match("test"),   nil)
  lu.assertEquals(pattern:match("teste"),  6  )
  lu.assertEquals(pattern:match("testes"), 6  )
end

os.exit(lu.LuaUnit.run())
