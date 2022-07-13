-- Exercise 2.1: Modify the eight-queen program so that it stops after printing
-- the first solution.

N = 8 -- board size

function isPlaceOk (a, n, c)
  for i = 1, n - 1 do
    if (a[i] == c) or (a[i] - i == c - n) or (a[i] + i == c + n) then
      return false
    end
  end

  return true
end

function printSolution (a)
  for i = 1, N do
    for j = 1, N do
      io.write(a[i] == j and "X" or "-", " ")
    end
    io.write("\n")
  end
  io.write("\n")
end

function addQueen (a, n)
  if n > N then
    printSolution(a)
    return true
  else
    for c = 1, N do
      if isPlaceOk(a, n, c) then
        a[n] = c
        if addQueen(a, n+1) then
          return true
        end
      end
    end
  end
end

addQueen({}, 1)

-- Exercise 2.2: An alternative implementation for the eight-queen problem
-- would be to generate all possible permutations of 1 to 8 and, for each
-- permutation, to check whether it is valid. Change the program to use this
-- approach.
-- How does the performance of the new program compare with the old one?
-- (Hint: compare the total number of permutations with the number of times
-- that the original program calls the function `isplaceok`)


-- 8 7 6 5 4 3 2 1
-- 8 6 4 2 0
