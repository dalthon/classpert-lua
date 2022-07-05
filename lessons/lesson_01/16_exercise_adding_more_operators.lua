-- Instructions

-- a) Add a remainder operator ('%') to the language, with the same priority as
--    the other multiplicative operators.

-- b) Add an exponential operator ('^') to the language, with a higher priority
--    than the multiplicative operators. Use the same concepts we used when we
--    added multiplicative operators. You will probably need a new kind of
--    expression, besides 'term' and 'exp'.

lpeg = require "lpeg"
lu   = require "luaunit"

P  = lpeg.P
R  = lpeg.R
S  = lpeg.S
C  = lpeg.C
Ct = lpeg.Ct
V  = lpeg.V

function parseNumber(number_and_spaces)
  local result = string.gsub(number_and_spaces, "[ \n\t]", "")
  return tonumber(result)
end

function fold (tokens)
  local accumulator = tokens[1]

  for i = 2, #tokens, 2 do
    if tokens[i] == "+" then
      accumulator = accumulator + tokens[i+1]
    elseif tokens[i] == "-" then
      accumulator = accumulator - tokens[i+1]
    elseif tokens[i] == "*" then
      accumulator = accumulator * tokens[i+1]
    elseif tokens[i] == "/" then
      accumulator = accumulator / tokens[i+1]
    elseif tokens[i] == "%" then
      accumulator = accumulator % tokens[i+1]
    elseif tokens[i] == "^" then
      accumulator = accumulator ^ tokens[i+1]
    else
      error("Unknown operator")
    end
  end

  return accumulator
end

exponential_op    = C(P("^"))
multiplicative_op = C(S("*/%"))
additive_op       = C(S("+-"))
unary_op          = S("+-")
number            = R("09")
space             = S(" \n\t")
blank             = space^0
numbers           = ((unary_op * blank * number^1) + number^1) / parseNumber

open_p  = P("(")
close_p = P(")")

primary = V("primary")
term    = V("term")
factor  = V("factor")
exp     = V("exp")

grammar = {
  "exp",
  primary = (numbers + (open_p * blank * exp * blank * close_p)) * blank,
  factor  = Ct(primary * blank * (exponential_op    * blank * primary * blank)^0 * blank) / fold,
  term    = Ct(factor  * blank * (multiplicative_op * blank * factor  * blank)^0 * blank) / fold,
  exp     = Ct(term    * blank * (additive_op       * blank * term    * blank)^0 * blank) / fold,
}

pattern = blank * grammar * -1

function testArithmeticOperations ()
  lu.assertEquals( {pattern:match("+1")},                  {1}    )
  lu.assertEquals( {pattern:match("1 + 20")},              {21}   )
  lu.assertEquals( {pattern:match("1 ++ 2")},              {3}    )
  lu.assertEquals( {pattern:match("1 ++-2")},              {nil}  )
  lu.assertEquals( {pattern:match("1 + -2")},              {-1}   )
  lu.assertEquals( {pattern:match("*1")},                  {nil}  )
  lu.assertEquals( {pattern:match("1 * 20")},              {20}   )
  lu.assertEquals( {pattern:match("1 *+ 2")},              {2}    )
  lu.assertEquals( {pattern:match("1 *+-2")},              {nil}  )
  lu.assertEquals( {pattern:match("1 * -2")},              {-2}   )
  lu.assertEquals( {pattern:match("^3")},                  {nil}  )
  lu.assertEquals( {pattern:match("2 ^ 10")},              {1024} )
  lu.assertEquals( {pattern:match("3 ^+ 2")},              {9}    )
  lu.assertEquals( {pattern:match("10 ^+-2")},             {nil}  )
  lu.assertEquals( {pattern:match("1 + 2*10^1 + 3*10^2")}, {321}  )

  lu.assertAlmostEquals(pattern:match("9 ^ -2"), 1.0/81, 0.001)
end

os.exit(lu.LuaUnit.run())
