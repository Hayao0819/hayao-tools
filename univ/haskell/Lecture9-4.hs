#!/usr/bin/env runghc

s :: Int -> Float
s n = sum (map (sqrt . fromIntegral) [1 .. n])

smallestN :: Int
smallestN = head (filter (\n -> s n > 1000) [1..])

main = do
    print smallestN
    print (s smallestN)
