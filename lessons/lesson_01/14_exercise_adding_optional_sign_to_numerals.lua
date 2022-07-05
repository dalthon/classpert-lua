-- Instructions

-- Add an optional sign ("+") or ("-") to numerals

lpeg = require "lpeg"
lu   = require "luaunit"

P  = lpeg.P
R  = lpeg.R
S  = lpeg.S
C  = lpeg.C
Cp = lpeg.Cp

function squeezeNumber(number_and_spaces)
  local result = string.gsub(number_and_spaces, "[ \n\t]", "")
  return tonumber(result)
end

number   = R("09")
unary_op = S("+-")
plus     = P("+")
space    = S(" \n\t")
numbers  = ((unary_op * space^0 * number^1) + number^1) / squeezeNumber

function testWithoutSpacesBetweenNumbers ()
  local pattern = space^0 * numbers * space^0 * (Cp() * plus * space^0 * numbers * space^0)^0 * -1

  lu.assertEquals( {pattern:match("+1")},     {1}        )
  lu.assertEquals( {pattern:match("-1")},     {-1}       )
  lu.assertEquals( {pattern:match("1 + 7")},  {1, 3, 7}  )
  lu.assertEquals( {pattern:match("1 ++ 7")}, {1, 3, 7}  )
  lu.assertEquals(  pattern:match("1 ++-7"),  nil        )
  lu.assertEquals( {pattern:match("1 + -7")}, {1, 3, -7} )
end

os.exit(lu.LuaUnit.run())
