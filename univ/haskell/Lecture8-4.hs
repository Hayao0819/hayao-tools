#!/usr/bin/env runghc

-- takeWhile :: (a -> Bool) -> [a] -> [a]
-- takeWhile _ [] = []
-- takeWhile f arr@(arr_first:arr_other)
--   | f arr_first = [arr_first] ++ Main.takeWhile f arr_other
--   | otherwise = []

-- main = print (Main.takeWhile (<10) [2,4,6,8,10,12])

oddSquareSum = sum (takeWhile (< 10000) ((^ 2) <$> filter odd [1 ..]))

main = print oddSquareSum
