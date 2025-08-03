#!/usr/bin/env runghc


myfunc1 = sum (filter (>10) (map (*2) [2..10]))

myfunc2 = sum $ filter (>10) $ map (*2) [2..10]
