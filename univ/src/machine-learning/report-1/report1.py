#!/usr/bin/env python3

import pandas as pd
import os
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import sklearn
import sklearn.discriminant_analysis
import sklearn.ensemble
import sklearn.linear_model
import sklearn.metrics
import sklearn.model_selection
import sklearn.preprocessing
import sklearn.svm
import sklearn.tree

import typing

# import types

dataDir = "./data"
modelResults: dict[str, dict[str, float]] = {}


def readCsv(name: str) -> pd.DataFrame:
    return pd.read_csv(os.path.join(dataDir, name))


train = readCsv("train.csv")
test = readCsv("test.csv")
genderSubmission = readCsv("gender_submission.csv")

ExitCode = int | str | None


def rawInfoCmd() -> None:
    train.info()
    print(train.head(5))


def preparedInfoCmd() -> None:
    prepared = getPreparedTrain()
    prepared.info()
    print(prepared.head(5))


# intのカラムを抽出する
# def dfFilterInt(d: pd.DataFrame) -> pd.DataFrame:
#     return d.select_dtypes(include=["Int32", "int", "Int64"])


def numericTrain(t: pd.DataFrame) -> pd.DataFrame:
    newdf = t.copy()
    return newdf[["Survived", "Pclass", "Age", "SibSp", "Parch", "Fare"]]


# 欠損値を補う
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
    newdf["isMale"] = (newdf["Sex"] == "male").astype(int)
    newdf["EmbarkedC"] = (newdf["Embarked"] == "C").astype(int)
    newdf["EmbarkedQ"] = (newdf["Embarked"] == "Q").astype(int)
    newdf["EmbarkedS"] = (newdf["Embarked"] == "S").astype(int)
    return newdf


def normalizedTrain(t: pd.DataFrame) -> pd.DataFrame:
    newdf = t.copy()
    scaler = sklearn.preprocessing.MinMaxScaler()
    newdf["Fare"] = scaler.fit_transform(newdf[["Fare"]])
    return newdf


def getPreparedTrain():
    df = completeTrain(train)
    return normalizedTrain(onehotTrain(df))


def learn():
    finaldf = getPreparedTrain()

    x = finaldf[
        [
            "Pclass",
            "Age",
            "SibSp",
            "Parch",
            "Fare",
            "isMale",
            "EmbarkedC",
            "EmbarkedS",
        ]
    ]
    y = finaldf["Survived"]

    return sklearn.model_selection.train_test_split(
        x, y, test_size=0.3, random_state=42
    )


def runModels(way: str | None = None) -> None:
    x_train, x_test, y_train, y_test = learn()

    # RunMethod = typing.Callable[[None], None]
    methodsList: dict[str, typing.Callable[[], dict[str, float]]] = {}

    def runLDA() -> dict:
        model = sklearn.discriminant_analysis.LinearDiscriminantAnalysis()
        model.fit(x_train, y_train)
        score = model.score(x_test, y_test)
        y_pred = model.predict(x_test)
        tn, fp, fn, tp = sklearn.metrics.confusion_matrix(y_test, y_pred).ravel()
        return {"score": score, "tn": int(tn), "tp": int(tp), "fn": int(fn), "fp": int(fp)}

    methodsList["LDA"] = runLDA

    def runSVM() -> dict:
        # 特徴量のスケーリング
        scaler = sklearn.preprocessing.StandardScaler()
        X_train_scaled = scaler.fit_transform(x_train)
        X_test_scaled = scaler.transform(x_test)

        svm_model = sklearn.svm.SVC(kernel="rbf", random_state=42)
        svm_model.fit(X_train_scaled, y_train)

        score = svm_model.score(X_test_scaled, y_test)
        y_pred = svm_model.predict(X_test_scaled)
        tn, fp, fn, tp = sklearn.metrics.confusion_matrix(y_test, y_pred).ravel()

        return {"score": score, "tn": int(tn), "tp": int(tp), "fn": int(fn), "fp": int(fp)}

    methodsList["SVM"] = runSVM

    def runQDA() -> dict:
        # 特徴量のスケーリング
        scaler = sklearn.preprocessing.StandardScaler()
        X_train_scaled = scaler.fit_transform(x_train)
        X_test_scaled = scaler.transform(x_test)

        # QDAモデルの訓練
        qda_model = sklearn.discriminant_analysis.QuadraticDiscriminantAnalysis()
        qda_model.fit(X_train_scaled, y_train)

        score = qda_model.score(X_test_scaled, y_test)

        # モデルの評価
        y_pred = qda_model.predict(x_test)
        tn, fp, fn, tp = sklearn.metrics.confusion_matrix(y_test, y_pred).ravel()

        return {"score": score, "tn": int(tn), "tp": int(tp), "fn": int(fn), "fp": int(fp)}

    methodsList["QDA"] = runQDA

    def runDecisionTree() -> dict:
        # 決定木モデルの訓練
        model = sklearn.tree.DecisionTreeClassifier(random_state=42)
        model.fit(x_train, y_train)

        score = model.score(x_test, y_test)
        y_pred = model.predict(x_test)
        tn, fp, fn, tp = sklearn.metrics.confusion_matrix(y_test, y_pred).ravel()

        # モデルの評価
        return {"score": score, "tn": int(tn), "tp": int(tp), "fn": int(fn), "fp": int(fp)}

    methodsList["DecisionTree"] = runDecisionTree

    def runRandomForest() -> dict:
        rf_model = sklearn.ensemble.RandomForestClassifier(
            n_estimators=100, random_state=42
        )
        rf_model.fit(x_train, y_train)
        y_pred = rf_model.predict(x_test)

        score = sklearn.metrics.accuracy_score(y_test, y_pred)
        tn, fp, fn, tp = sklearn.metrics.confusion_matrix(y_test, y_pred).ravel()

        return {"score": score, "tn": int(tn), "tp": int(tp), "fn": int(fn), "fp": int(fp)}

    methodsList["RandomForest"] = runRandomForest

    if way == None or way == "":
        for [name, m] in methodsList.items():
            modelResults[name] = m()
    else:
        way = str(way)
        modelResults[way] = methodsList[way]()


def showModelScores() -> None:
    print(
        dict(
            sorted(
                modelResults.items(), key=lambda item: item[1]["score"], reverse=True
            )
        )
    )


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


def graphPreparedCorrCmd() -> None:
    t = getPreparedTrain()[
        [
            "Survived",
            "Pclass",
            "Age",
            "SibSp",
            "Parch",
            "Fare",
            "isMale",
            "EmbarkedC",
            "EmbarkedQ",
            "EmbarkedS",
        ]
    ]

    # 相関係数行列の計算
    correlation_matrix = t.corr()

    # ヒートマップの作成
    plt.figure(figsize=(12, 10))
    sns.heatmap(
        correlation_matrix, annot=True, cmap="coolwarm", vmin=-1, vmax=1, center=0
    )
    plt.title("Correlation Heatmap of Numeric Features")
    plt.show()

    t.info()


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


def graphEnumValue(feature: str) -> int:
    enum_keys = ["Pclass", "Sex", "Embarked", "SibSp", "Parch"]

    if not feature in enum_keys:
        print(f"Please specify culumn from {enum_keys}", file=sys.stderr)
        return 1

    t = getPreparedTrain()

    plt.figure(figsize=(12, 5))

    # 左側のプロット：カテゴリの分布
    plt.subplot(1, 2, 1)
    sns.countplot(data=t, x=feature)
    plt.title(f"Distribution of {feature}")

    # 右側のプロット：カテゴリごとの生存率
    plt.subplot(1, 2, 2)
    sns.barplot(data=t, x=feature, y="Survived")
    plt.title(f"Survival Rate by {feature}")
    plt.ylabel("Survival Rate")

    plt.tight_layout()
    plt.show()
    return 0


def titanicCmd(arg: str | None = None) -> None:
    runModels(arg)
    showModelScores()


def completedInfoCmd() -> None:
    completeTrain(train).info()


def graphPclass() -> None:
    t = completeTrain(train)

    f, ax = plt.subplots(1, 3, figsize=(15, 4))
    sns.histplot(t[t["Pclass"] == 1]["Fare"], ax=ax[0])
    ax[0].set_title("Fares in Pclass 1")
    sns.histplot(t[t["Pclass"] == 2]["Fare"], ax=ax[1])
    ax[1].set_title("Fares in Pclass 2")
    sns.histplot(t[t["Pclass"] == 3]["Fare"], ax=ax[2])
    ax[2].set_title("Fares in Pclass 3")
    plt.show()


def main() -> ExitCode:
    match sys.argv[1] if len(sys.argv) != 1 else "":
        case "prepared-info":
            preparedInfoCmd()
        case "completed-info":
            completedInfoCmd()
        case "raw-info":
            rawInfoCmd()
        case "graph-prepared-corr":
            graphPreparedCorrCmd()
        case "graph-corr":
            graphCorrCmd()
        case "graph-survive":
            graphSurviveCorr()
        case "graph-enum":
            return graphEnumValue(sys.argv[2] if len(sys.argv) >= 3 else "")
        case "graph-pclass":
            graphPclass()
        case "" | "run":
            titanicCmd(sys.argv[2] if len(sys.argv) >= 3 else None)
        case _:
            print("Undefined command", file=sys.stderr)
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
