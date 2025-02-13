#!/usr/bin/env python3

import cv2
import numpy as np


def calcPxPerMetre(rulerImg: cv2.typing.MatLike) -> float | None:
    imgNpArray = np.asarray(rulerImg)
    hight, width, _ = imgNpArray.shape

    for x in range(width):
        topPix = imgNpArray[0, x]
        changeYList = []
        continuousChanges = []

        prevChanged = False
        for y in range(1, hight):
            if (topPix != imgNpArray[y, x]).any():
                prevChanged = True
                continuousChanges += [y]
            else:
                if prevChanged:
                    prevChanged = False
                    changeYList += [continuousChanges]
                    continuousChanges = []

        if len(changeYList) != 0:
            avgYList = [sum(p) / len(p) for p in changeYList]
            dyList = [avgYList[i + 1] - avgYList[i] for i in range(len(avgYList) - 1)]
            return (sum(dyList) / len(dyList)) * 10
    return None


def calcBallsY(pxPerMetre: float, ballsImg: cv2.typing.MatLike):
    imgNpArray = np.asarray(ballsImg)
    hight, width, _ = imgNpArray.shape

    for x in range(width):
        topPixel = imgNpArray[0, x]
        changeYList = []
        continuousChanges = []

        prevChanged = False
        for y in range(1, hight):
            if (topPixel != imgNpArray[y, x]).any():
                prevChanged = True
                continuousChanges += [y]
            else:
                if prevChanged:
                    prevChanged = False
                    changeYList += [continuousChanges]
                    continuousChanges = []

        if len(changeYList) != 0:
            avgYList = [sum(p) / len(p) for p in changeYList]
            yList = [(i - min(avgYList)) / pxPerMetre for i in avgYList]
            return yList


def listNumericDiff(argList, virgin):
    res = []
    for i in range(len(argList) - 1):
        res += [(argList[i + 1] - argList[i]) / virgin]

    return res
