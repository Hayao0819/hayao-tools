#!/usr/bin/env runghc

function :: (Floating a, Ord a) => a -> a
function x = sin $ negate $ tan $ cos $ max 50 x
