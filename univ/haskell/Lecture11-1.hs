#!/usr/bin/env runghc

type Name = String

type Number = String

type StudentInfo = [(Name, Number)]

student :: StudentInfo
student = [("Gunma Taro", "J001"), ("Gunma Jiro", "J002"), ("Akagi Hanako", "J003")]

inStudentList :: Name -> Number -> Bool
inStudentList name number =  (name, number) `elem` student

main = print (inStudentList "Gunma Taro" "J001")
