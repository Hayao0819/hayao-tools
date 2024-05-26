from random import random, randint


# [-0.01, 0.01] のノイズを適応
def noise(num):
    unsignedCoef = random() * 0.01
    sign = -(1 ** randint(0, 1))
    coef = unsignedCoef * sign
    return num + (num * coef)
