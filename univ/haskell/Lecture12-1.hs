#!/usr/bin/env runghc
import Text.Blaze.Html4.Strict (a)

data Tree a = EmptyTree | Node a (Tree a) (Tree a) deriving (Show)

treeInsert :: Ord a => a -> Tree a -> Tree a
treeInsert x EmptyTree = Node x EmptyTree EmptyTree
treeInsert x (Node a left right)
  | x == a = Node a left right
  | x < a = Node a (treeInsert x left) right
  | x > a = Node a left (treeInsert x right)

binarySearchTree :: Ord a => [a] -> Tree a
binarySearchTree = foldr treeInsert EmptyTree

nodeValue = [8, 6, 4, 1, 7, 3, 5]

main = print (binarySearchTree nodeValue)
