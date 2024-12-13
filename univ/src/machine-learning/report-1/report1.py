#!/usr/bin/env python3

import pandas as pd
import os
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import sklearn

dataDir = "./data"


def readCsv(name: str) -> pd.DataFrame:
    return pd.read_csv(os.path.join(dataDir, name))


train = readCsv("train.csv")
test = readCsv("test.csv")
genderSubmission = readCsv("gender_submission.csv")


def infoCmd() -> None:
    print("train")
    train.info()
    train.head(5)


# intのカラムを抽出する
def dfFilterInt(d: pd.DataFrame) -> pd.DataFrame:
    return d.select_dtypes(include=["Int32", "int", "Int64"])


def numericTrain(t: pd.DataFrame) -> pd.DataFrame:
    newdf = t.copy()
    return newdf[["Survived", "Pclass", "Age", "SibSp", "Parch", "Fare"]]


# 欠損値を補い
def completeTrain(t: pd.DataFrame) -> pd.DataFrame:
    newdf = t.copy()

    # 欠損しているAgeを平均値
    ageAve = newdf["Age"].mean()
    newdf["Age"].fillna(ageAve, inplace=True)

    # Cabinは非常に欠損値が多いので削除
    newdf.drop("Cabin", axis=1, inplace=True)

    return newdf


def getCompletedNumericTrain() -> pd.DataFrame:
    return numericTrain(completeTrain(train))


def onehotTrain(t: pd.DataFrame) -> pd.DataFrame:
    newdf = t.copy()
    newdf["is_male"] = (newdf["Sex"] == "male").astype(int)
    newdf["Embarked_C"] = (newdf["Embarked"] == "C").astype(int)
    newdf["Embarked_Q"] = (newdf["Embarked"] == "Q").astype(int)
    newdf["Embarked_S"] = (newdf["Embarked"] == "S").astype(int)
    return newdf


def normalizedTrain(t: pd.DataFrame) -> pd.DataFrame:
    newdf = t.copy()
    scaler = sklearn.preprocessing.MinMaxScaler()
    newdf["Fare"] = scaler.fit_transform(newdf[["Fare"]])
    return newdf


def getPreparedTrain():
    df = completeTrain(train)
    return normalizedTrain(onehotTrain(df))


def graphCorrCmd() -> None:
    edited_train = getCompletedNumericTrain()

    # 相関係数行列の計算
    correlation_matrix = edited_train.corr()

    # ヒートマップの作成
    plt.figure(figsize=(12, 10))
    sns.heatmap(
        correlation_matrix, annot=True, cmap="coolwarm", vmin=-1, vmax=1, center=0
    )
    plt.title("Correlation Heatmap of Numeric Features")
    plt.show()

    edited_train.info()


def graphSurviveCorr() -> None:
    edited_train = getCompletedNumericTrain()
    survival_correlation = edited_train["Survived"].abs().sort_values(ascending=False)

    # バープロットの作成
    plt.figure(figsize=(10, 6))
    survival_correlation.plot(kind="bar")
    plt.title("Correlation with Survival")
    plt.xlabel("Features")
    plt.ylabel("Absolute Correlation")
    plt.show()


def titanicCmd() -> None:
    prepared = getPreparedTrain()
    prepared.info()
    print(prepared.head(3))


def main() -> int:
    if len(sys.argv) == 1:
        titanicCmd()
    else:
        match sys.argv[1]:
            case "info":
                infoCmd()
            case "graph-corr":
                graphCorrCmd()
            case "graph-survive":
                graphSurviveCorr()
            case _:
                return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
