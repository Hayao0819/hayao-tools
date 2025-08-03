#!/usr/bin/env runghc

reverse :: [a] -> [a]
reverse = foldl (flip (:)) []

main = print (Main.reverse [1,2,3,4,5])
