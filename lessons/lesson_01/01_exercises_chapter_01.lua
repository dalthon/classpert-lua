-- Exercise 1.1: Run the factorial example.
-- What happens to your program if you enter a negative number?
-- Modify the example to avoid this problem.
-- Answer:

function fact (n)
  if n > 0 then
    return n * fact(n-1)
  end

  if n == 0 then
    return 1
  end

  error("Should not use negative numbers")
end

-- Exercise 1.2: Run the `twice` example.
-- Both by loading the file with the `-l` option and with `dofile`.
-- Which way do you prefer?
-- Answer: Done!

-- Exercise 1.3: Can you name other languages that use "--" for comments?
-- Answer: SQL?

-- Exercise 1.4: Which of the following strings are valid identifiers?
-- ___ _end End end until? nil NULL one-step
-- Answer: ___ _end End NULL

-- Exercise 1.5: What is the value of the expression `type(nil) == nil`?
-- (You can use Lua to check your answer.) Can you explain this result?
-- Answer: false, "nil" != nil

-- Exercise 1.6: How can you check whether a value is a Boolean without using the function `type`?
-- Answer: `value == false or value == true`

-- Exercise 1.7: Consider the following expression: `(x and y and (not z)) or ((not y) and x)`
-- Are the parentheses necessary? Would you recommend their use in that expression?
-- Answer: Not necessary, totally recommended due to readability

-- Exercise 1.8: Write a simple script that prints its own name without knowing it in advance.
-- Answer:
print(arg[0])
