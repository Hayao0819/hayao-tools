#!/usr/bin/env runghc
import Data.List (sort, nub)

triples = [(a, b, c) | a <- [1..10], b <- [1..10], c <- [1..10]] ::  [(Int, Int, Int)]

type Triangle = (Int, Int, Int)


isRight :: Triangle-> Bool
isRight (a, b, c) = a^2 + b^2 == c^2  && a + b + c == 24

sortedEdgeList :: Triangle -> [Int]
sortedEdgeList (a, b, c) = sort [a, b, c]

rightTriangles = nub . sortedEdgeList <$> filter isRight triples

main = do
    print rightTriangles
    putStrLn ("総数 " ++ show (length rightTriangles))
