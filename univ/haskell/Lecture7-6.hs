#!/usr/bin/env runghc


-- 何故かこれ動かないです

class QuickSortable a where
  pickPivot :: [a] -> a
  pickPivot (top : _) = top
  before :: Ord a => a -> [a] -> [a]
  before pivot arr = filter (\n -> n < pivot) arr
  after :: Ord a => a -> [a] -> [a]
  after pivot arr = filter (\n -> n >= pivot) arr

-- instance Ord a => QuickSortable a

-- quicksort :: Ord a => [a] -> [a]
-- quicksort [] = []
-- quicksort arr = sortedBefore ++ [pivot] ++ sortedAfter
--   where
--     pivot = pickPivot arr
--     sortedBefore = quicksort (before pivot arr)
--     sortedAfter = quicksort (after pivot arr)

-- main = do
--   print (quicksort ([1, 2, 4, 2, 7, 9, 6] :: [Int]))

