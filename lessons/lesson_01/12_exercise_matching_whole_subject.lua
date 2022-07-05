-- Instructions

-- Modify the previous exercise so that it only succeeds if it matches the whole subject.

lpeg = require "lpeg"
lu   = require "luaunit"

P  = lpeg.P
R  = lpeg.R
S  = lpeg.S
C  = lpeg.C
Cp = lpeg.Cp

number  = R("09")
numbers = number^1 / tonumber
space   = S(" \n\t")
plus    = P("+")

function squeezeNumber(number_and_spaces)
  local result = string.gsub(number_and_spaces, "[ \n\t]", "")
  return tonumber(result)
end

function testWithoutSpacesBetweenNumbers ()
  local pattern = space^0 * numbers * space^0 * (Cp() * plus * space^0 * numbers * space^0)^0 * -1

  lu.assertEquals( {pattern:match("1")}, {1}  )
  lu.assertEquals(  pattern:match("1a"),  nil  )
end

function testWithSpacesBetweenNumbers ()
  local spaced_numbers = space^0 * number * (space + number)^0 / squeezeNumber
  local pattern        = spaced_numbers * (Cp() * plus * spaced_numbers)^0 * -1

  lu.assertEquals( {pattern:match("1 2")}, {12} )
  lu.assertEquals(  pattern:match("1 2a"), nil  )
end

os.exit(lu.LuaUnit.run())
