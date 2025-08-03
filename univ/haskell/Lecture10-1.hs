#!/usr/bin/env runghc

digitSum :: Int -> Int
digitSum 0 = 0
digitSum n = (n `mod` 10) + digitSum (n `div` 10)


main = do
  print (digitSum 123) 
  print (digitSum 512)
