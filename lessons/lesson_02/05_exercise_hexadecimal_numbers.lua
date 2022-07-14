-- Instructions

-- Change the program to also accept hexadecimal numbers, in the format usually
-- used by other programming languages. Make sure to accept both upper and
-- lower-case letters, both for the initial "X" and for the hex digits.
-- (Once you match the numeral, you can use the Lua function `tonumber`
-- directly on it.)

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

local open_p      = P("(")     * space
local close_p     = P(")")     * space
local additive_op = C(S("+-")) * space

local integer     = number^1
local hex_decimal = (hex_init   * hex_number^1)
local numeral     = (hex_decimal + integer) / node * space

local primary = V("primary")
local exp     = V("exp")

local grammar = {
  "exp",
  primary = (numeral + (open_p * exp * close_p)),
  exp     = Ct(primary * (additive_op * primary)^0) / foldBin,
}

local grammar = space * grammar * -1

local function parse (input)
  return grammar:match(input)
end

function testParser ()
  lu.assertEquals( parse("1"),        {tag = "number", value = 1})
  lu.assertEquals( parse("0x02"),     {tag = "number", value = 2})
  lu.assertEquals( parse("0x0a + 1"), {op = "+", left = {value = 10, tag = "number"}, right = {value = 1, tag = "number"}, tag = "binop"})
end

-- Compiler

local operations = {
  ["+"]  = "add",
  ["-"]  = "sub",
  ["*"]  = "mul",
  ["/"]  = "div",
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
  lu.assertEquals( compile(parse("1")),        {"push", 1})
  lu.assertEquals( compile(parse("0x02")),     {"push", 2})
  lu.assertEquals( compile(parse("0x0a + 1")), {"push", 10, "push", 1, "add"})
end

-- Interpreter

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
      stack[top-1] = stack[top-1] + stack[top]
      top          = top - 1
    elseif code[pc] == "sub" then
      stack[top-1] = stack[top-1] - stack[top]
      top          = top - 1
    elseif code[pc] == "mul" then
      stack[top-1] = stack[top-1] * stack[top]
      top          = top - 1
    elseif code[pc] == "div" then
      stack[top-1] = stack[top-1] / stack[top]
      top          = top - 1
    else
      error("unknown instruction")
    end
    pc = pc + 1
  end

  return stack[1]
end

function testInterpreter ()
  lu.assertEquals( run(compile(parse("1"))),        1)
  lu.assertEquals( run(compile(parse("0x02"))),     2)
  lu.assertEquals( run(compile(parse("0x0a + 1"))), 11)
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
