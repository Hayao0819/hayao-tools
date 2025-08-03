#!/usr/bin/env runghc


productVer1 :: [Int] -> Int
productVer1  = foldl (*) 1 

productVer2 :: [Int] -> Int
productVer2 = foldl1 (*)

main = do
    print (productVer1 [1,2,3,4,5])
    print (productVer2 [1,2,3,4,5])
