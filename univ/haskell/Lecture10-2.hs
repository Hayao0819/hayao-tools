#!/usr/bin/env runghc

import Data.List

digitSum :: Int -> Int
digitSum 0 = 0
digitSum n = (n `mod` 10) + digitSum (n `div` 10)

findFirst40 :: Maybe Int
findFirst40 = find (\n -> digitSum n > 40)  [1..]

main :: IO()
main = case findFirst40 of
    Just n  -> print n
    Nothing -> putStrLn "No number found"
