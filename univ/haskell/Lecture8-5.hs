#!/usr/bin/env runghc
import Basement.Bits (FiniteBitsOps(numberOfBits))

doCollatzOp :: Int -> Int
doCollatzOp a
  | a == 1 = 1
  | even a = a `div` 2
  | otherwise = 3 * a + 1

collatz :: Int -> [Int]
collatz 1 = []
collatz a = do
  let next = doCollatzOp a
  next : collatz next

-- (1) main = print (collatz 3)


numCollatz = filter (\n -> length (collatz n) >= 15)  [1..100]

main = print numCollatz
