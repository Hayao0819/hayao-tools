#!/usr/bin/env runghc

type Result = (Char , Int)

results :: [Result]
results = [('a', 85),('b', 60),('a', 70),('a', 100),('b', 55), ('a', 70) :: Result]

find :: [Result] -> Char -> [Result]
find l x = filter (\(c, _) -> c == x) l

main = do
    let res = find results 'a'
    print (map (\(_, score) -> score) res)
