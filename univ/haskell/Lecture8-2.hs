#!/usr/bin/env runghc

isUpper :: Char -> Bool
isUpper = (`elem` ['A' .. 'Z'])

main = do
    print (isUpper 'A')
    print (isUpper 'n')
