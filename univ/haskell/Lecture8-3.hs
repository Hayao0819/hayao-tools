#!/usr/bin/env runghc

-- zipWith<T>(f: func(a:T,b:T):T, arr1: []T, arr2: []T):[]T
zipWith :: (a -> a -> a) -> [a] -> [a] -> [a]
zipWith _ [] [] = []
zipWith f (arr1_0 : arr1_other) (arr2_0 : arr2_other) = (++) [f arr1_0 arr2_0] (Main.zipWith f arr1_other arr2_other)


main = print (Main.zipWith (++) ["Gunma", "Haruna", "Myogi"] ["Taro", "Jiro", "Saburo"])
