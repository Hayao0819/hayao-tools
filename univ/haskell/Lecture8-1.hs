#!/usr/bin/env runghc

data Result = GT | EQ | LT deriving Show

myCompare :: Int -> Int -> Result
myCompare a b 
 | a > b = Main.GT
 | a == b = Main.EQ
 | otherwise = Main.LT

compareWithSeven :: Int -> Result
compareWithSeven a = myCompare 7 a

main = print (compareWithSeven 7)


