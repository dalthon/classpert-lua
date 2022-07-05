-- Instructions

-- Write a pattern that matches a non-empty list of numerals intercalated with
-- the plus operator ("+"). A plus operator can only appear between two
-- numerals. Make sure your pattern allows spaces around any element (numerals
-- and operators)

lpeg = require "lpeg"
lu   = require "luaunit"

P = lpeg.P
R = lpeg.R
S = lpeg.S

number  = R("09")
numbers = number^1
space   = S(" \n\t")
plus    = P("+")

function testWithoutSpacesBetweenNumbers ()
  local pattern = space^0 * numbers * space^0 * (plus * space^0 * numbers * space^0)^0

  lu.assertEquals(pattern:match( "1",            2  ))
  lu.assertEquals(pattern:match( " 1",           3  ))
  lu.assertEquals(pattern:match( "1 ",           3  ))
  lu.assertEquals(pattern:match( "12",           3  ))
  lu.assertEquals(pattern:match( "1+2",          4  ))
  lu.assertEquals(pattern:match( " 1 + 2 + 34 ", 13 ))
end

function testWithSpacesBetweenNumbers ()
  local spaced_numbers = space^0 * number * (space + number)^0
  local pattern        = spaced_numbers * (plus * spaced_numbers)^0

  lu.assertEquals(pattern:match( "1 2",            5  ))
  lu.assertEquals(pattern:match( "1 0 + 2 0",      10 ))
  lu.assertEquals(pattern:match( " 1 + 20 + 3 4 ", 15 ))
end

os.exit(lu.LuaUnit.run())
