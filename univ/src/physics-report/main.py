#!/usr/bin/env python3

import matplotlib
import matplotlib.pyplot as plt
import japanize_matplotlib
import cv2
import numpy as np
import base64
import pandas as pd
import os

import noise
import ballimg
import utils

strobeInterval = 1 / 30

matplotlib.use('Agg') 


def getBallsImg() -> cv2.typing.MatLike:
    return cv2.imread("balls.png")


def getRulerImg():
    return cv2.imread("ruler.png")

rulerImg = getRulerImg()
ballsImg = getBallsImg()

def drawGraph():
    rawY = ballimg.calcBallsY(ballimg.calcPxPerMetre(rulerImg), ballsImg)
    y = list(map(noise.noise, rawY))
    # y = calcBallsY(calcPxPerMetre())
    v = utils.listNumericDiff(y, strobeInterval)
    a = utils.listNumericDiff(v, strobeInterval)

    t_y = [strobeInterval * i for i in range(len(y))]
    t_v = [strobeInterval / 2 + i for i in t_y][:-1]
    t_a = [(t_v[0] + t_v[1]) / 2 + i for i in t_v][:-1]

    # XTグラフ
    def drawXTGraph():
        plt.title("物体の位置と時刻の関係")
        plt.ylabel("物体の位置 (m)")
        plt.xlabel("時刻 (sec)")

        plt.plot(t_y, y, marker="o", linestyle="dotted")
        plt.savefig("output/XTGraph.png")
    
    def drawVTGraph():
        plt.title("物体の平均速度と時刻の関係")
        plt.ylabel("平均速度 (m/s)")
        plt.xlabel("時刻 (sec)")
        plt.plot(t_v, v, marker="o",linestyle="dotted")
        plt.savefig("output/VTGraph.png")

    def drawATGraph():
        plt.title("物体の平均加速度と時刻の関係")
        plt.ylabel("平均加速度 ($m/s^2$)")
        plt.xlabel("時刻 (sec)")
        plt.plot(t_a, a, marker="o", linestyle="dotted")
        plt.savefig("output/ATGraph.png")

    drawXTGraph()
    drawVTGraph()
    drawATGraph()
    


def main(img_path: str = "img.png"):
    os.mkdir("output")
    drawGraph()

if __name__ == "__main__":
    main()
