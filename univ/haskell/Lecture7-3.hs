#!/usr/bin/env runghc

myrev :: [a] -> [a]
myrev [] = []
myrev arr@(top : other) = myrev other ++ [top]

main = print (myrev [1, 2, 3])
