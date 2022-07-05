-- Instructions

-- Modify the previous exercise so that it returns all numerals in the subject
-- intercalated with the positions of the intercalated plus operators, like
-- this:

--   print(patt:match("12+13+25"))
--   --> 12 3 13 6 25

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
  local pattern = space^0 * numbers * space^0 * (Cp() * plus * space^0 * numbers * space^0)^0

  lu.assertEquals( {pattern:match("1")},            {1}              )
  lu.assertEquals( {pattern:match(" 1")},           {1}              )
  lu.assertEquals( {pattern:match("1 ")},           {1}              )
  lu.assertEquals( {pattern:match("12")},           {12}             )
  lu.assertEquals( {pattern:match("1+2")},          {1, 2, 2}        )
  lu.assertEquals( {pattern:match(" 1 + 2 + 34 ")}, {1, 4, 2, 8, 34} )
end

function testWithSpacesBetweenNumbers ()
  local spaced_numbers = space^0 * number * (space + number)^0 / squeezeNumber
  local pattern        = spaced_numbers * (Cp() * plus * spaced_numbers)^0

  lu.assertEquals( {pattern:match("1 2")},            {12}              )
  lu.assertEquals( {pattern:match("1 0 + 2 0")},      {10, 5, 20}       )
  lu.assertEquals( {pattern:match(" 1 + 20 + 3 4 ")}, {1, 4, 20, 9, 34} )
end

os.exit(lu.LuaUnit.run())
