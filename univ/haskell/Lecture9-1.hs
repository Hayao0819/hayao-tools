#!/usr/bin/env runghc

odds :: Int -> [Int]
odds = \n -> take n (filter odd [1..])

main = print (odds 5)
