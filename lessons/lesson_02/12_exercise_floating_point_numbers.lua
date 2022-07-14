-- Instructions

-- a) Change the definition of numeral so that it can match floating-point
--    numbers like `0.1` and `13.25`. It is up to you whether the syntax would
--    also accept things like `0.` or `.5`.
--    (You probably won't need to change anything in the captures for this
--    feature as all operations we used naturally handle floats)

-- b) Add scientific notation ("E notation") to the previous definition, so
--    that we can write numbers like `0.5E-3` and `123e12`.
--    (Again, you probably won't need to change anything in the captures)

pt = require("pt").pt
lu = require "luaunit"

-- Parser

local lpeg = require "lpeg"
local P    = lpeg.P
local R    = lpeg.R
local S    = lpeg.S
local C    = lpeg.C
local Ct   = lpeg.Ct
local V    = lpeg.V

local function node (number)
  local trimmed_number = string.gsub(number, "[ \n\t]", "")
  return {
    tag   = "number",
    value = tonumber(trimmed_number)
  }
end

local function foldBin (tokens)
  local tree = tokens[1]
  for i = 2, #tokens, 2 do
    tree = {
      tag   = "binop",
      left  = tree,
      op    = tokens[i],
      right = tokens[i+1],
    }
  end
  return tree
end

local space       = S(" \n\t")^0
local number      = R("09")
local float_point = P(".")
local sci_exp     = S("eE")
local hex_init    = P("0x") + P("0X")
local hex_number  = R("09") + R("af") + R("AF")

local open_p            = P("(")      * space
local close_p           = P(")")      * space
local exponential_op    = C(P("^"))   * space
local multiplicative_op = C(S("*/%")) * space
local additive_op       = C(S("+-"))  * space
local unary_minus       = P("-")      * space
local lt_op             = C(P("<"))   * space
local gt_op             = C(P(">"))   * space
local gte_op            = C(P(">="))  * space
local lte_op            = C(P("<="))  * space
local eq_op             = C(P("=="))  * space
local neq_op            = C(P("!="))  * space
local relational_op     = (gte_op + lte_op + neq_op + gt_op + lt_op + eq_op)

local integer     = (unary_minus^-1 * number^1)
local decimal     = integer * (float_point * number^1)^-1
local sci_num     = decimal * (sci_exp * integer)^-1
local hex_decimal = (hex_init   * hex_number^1)
local numeral     = (hex_decimal + sci_num) / node * space

local primary = V("primary")
local term    = V("term")
local factor  = V("factor")
local add_exp = V("add_exp")
local exp     = V("exp")

local grammar = {
  "exp",
  primary = (numeral + (open_p * exp * close_p)),
  factor  = Ct(primary * (exponential_op    * primary)^0) / foldBin,
  term    = Ct(factor  * (multiplicative_op * factor )^0) / foldBin,
  add_exp = Ct(term    * (additive_op       * term   )^0) / foldBin,
  exp     = Ct(add_exp * (relational_op     * add_exp)^0) / foldBin,
}

local grammar = space * grammar * -1

local function parse (input)
  return grammar:match(input)
end

function testParser ()
  lu.assertEquals( parse("12e2"),        {tag = "number", value = 1200})
  lu.assertEquals( parse("3.14"),        {tag = "number", value = 3.14})
  lu.assertEquals( parse("3.14e2"),      {tag = "number", value = 314})
  lu.assertEquals( parse("12e2 + 3.14"), {op = "+", left = {tag = "number", value = 1200}, right = {tag = "number", value = 3.14}, tag = "binop"})
end

-- Compiler

local operations = {
  ["+"]  = "add",
  ["-"]  = "sub",
  ["*"]  = "mul",
  ["/"]  = "div",
  ["%"]  = "mod",
  ["^"]  = "pow",
  ["<"]  = "lt",
  [">"]  = "gt",
  [">="] = "gte",
  ["<="] = "lte",
  ["=="] = "eq",
  ["!="] = "neq",
}

local function addCode (state, op)
  local code = state.code
  code[#code + 1] = op
end

local function codeExp (state, ast)
  if ast.tag == "number" then
    addCode(state, "push")
    addCode(state, ast.value)
  elseif ast.tag == "binop" then
    codeExp(state, ast.left)
    codeExp(state, ast.right)
    addCode(state, operations[ast.op])
  else
    error("Invalid ast")
  end
end

local function compile (ast)
  local state = {code = {}}
  codeExp(state, ast)
  return state.code
end

function testCompiler ()
  lu.assertEquals( compile(parse("12e2")), {"push", 1200})
  lu.assertEquals( compile(parse("3.14")), {"push", 3.14})
end

-- Interpreter

local verbose = arg[1] == "debug"

local function run (code)
  local stack = {}
  local pc    = 1
  local top   = 0

  while pc <= #code do
    if code[pc] == "push" then
      pc  = pc  + 1
      top = top + 1
      stack[top] = code[pc]
    elseif code[pc] == "add" then
      if verbose then print("add", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] + stack[top]
      top          = top - 1
    elseif code[pc] == "sub" then
      if verbose then print("sub", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] - stack[top]
      top          = top - 1
    elseif code[pc] == "mul" then
      if verbose then print("mul", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] * stack[top]
      top          = top - 1
    elseif code[pc] == "div" then
      if verbose then print("div", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] / stack[top]
      top          = top - 1
    elseif code[pc] == "mod" then
      if verbose then print("mod", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] % stack[top]
      top          = top - 1
    elseif code[pc] == "pow" then
      if verbose then print("pow", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] ^ stack[top]
      top          = top - 1
    elseif code[pc] == "lt" then
      if verbose then print("lt", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] < stack[top] and 1 or 0
      top          = top - 1
    elseif code[pc] == "gt" then
      if verbose then print("gt", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] > stack[top] and 1 or 0
      top          = top - 1
    elseif code[pc] == "gte" then
      if verbose then print("gte", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] >= stack[top] and 1 or 0
      top          = top - 1
    elseif code[pc] == "lte" then
      if verbose then print("lte", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] <= stack[top] and 1 or 0
      top          = top - 1
    elseif code[pc] == "eq" then
      if verbose then print("eq", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] == stack[top] and 1 or 0
      top          = top - 1
    elseif code[pc] == "neq" then
      if verbose then print("neq", stack[top-1], stack[top]) end
      stack[top-1] = stack[top-1] ~= stack[top] and 1 or 0
      top          = top - 1
    else
      error("unknown instruction")
    end
    pc = pc + 1
  end

  return stack[1]
end

function testInterpreter ()
  lu.assertEquals( run(compile(parse("12e3 + 3.14"))), 12003.14)
end

-- Debug

if arg[1] == "debug" then
  local input = io.read("a")
  print("input:", input)

  print("ast:")
  local ast = parse(input)
  print(pt(ast))

  print("code:")
  local code = compile(ast)
  print(pt(code))

  print("execution:")
  print(run(code))
end

-- Test
os.exit(lu.LuaUnit.run())
