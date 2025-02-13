#!/usr/bin/env python3

def listNumericDiff(argList, virgin):
    res = []
    for i in range(len(argList) - 1):
        res += [(argList[i + 1] - argList[i]) / virgin]

    return res
