#!/usr/bin/env python3
import sys
import pandas as pd
import os
import glob
import os.path as path
import collections
import matplotlib.pyplot as plt
import seaborn as sns
import japanize_matplotlib  # type: ignore
import re
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import BernoulliNB
from sklearn.metrics import classification_report
from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.metrics import f1_score
from sklearn.metrics import confusion_matrix
import numpy as np

script_dir = path.dirname(__file__)
data_dir = path.join(script_dir, "data")
out_dir = path.join(script_dir, "out")
if not path.exists(out_dir):
    os.makedirs(out_dir, exist_ok=True)


# Read the data
def read_train_data():
    train_files = pd.DataFrame(columns=["mail"])
    for file in glob.glob(path.join(data_dir, "train2", "*.txt")):
        file_name = path.basename(file)
        lines = open(file, encoding="utf-8").read()
        train_files.loc[file_name, "mail"] = lines

    master = pd.read_csv(
        path.join(data_dir, "train_master.tsv"), sep="\t", index_col="file_name"
    )
    train_files = train_files.merge(
        master, left_index=True, right_index=True, how="left"
    )
    # print(train_files)
    return train_files


def read_test_data():
    test_files = pd.DataFrame(columns=["mail"])
    for file in glob.glob(path.join(data_dir, "test2", "*.txt")):
        file_name = path.basename(file)
        lines = open(file, encoding="utf-8").read()
        test_files.loc[file_name, "mail"] = lines
    test_files["filename"] = test_files.index
    test_files.reset_index(drop=True, inplace=True)
    # print(test_files)
    return test_files


def parse_mail(data: pd.DataFrame) -> pd.DataFrame:
    data["subject"] = (
        data["mail"].str.split("\n").str[0].replace(r"^Subject:\s*", "", regex=True)
    )
    data["body"] = data["mail"].str.split("\n").str[1:].str.join(" ")
    data["counter"] = data["body"].str.split(" ").apply(collections.Counter)
    data["length"] = data["body"].str.len()
    data["words"] = data["counter"].apply(lambda x: sum(x.values()))
    return data


def show_info(data: pd.DataFrame):
    print("データの先頭10行:")
    print(data.head(10))
    print("\nデータの型情報:")
    print(data.dtypes)
    print("\nデータの概要:")
    print(data.describe(include='all'))

# 'out' ディレクトリが存在しない場合は作成
if not os.path.exists("out"):
    os.makedirs("out")


# メール本文の長さのヒストグラムを保存する関数
def save_email_body_length_histogram(data: pd.DataFrame):
    plt.figure(figsize=(12, 6))
    sns.histplot(
        data=data,
        x="length",
        hue="label",
        kde=True,
        palette="coolwarm",
        bins=30,
        multiple="stack",
    )
    plt.title("メール本文の長さのヒストグラム")
    plt.xlabel("メール本文の長さ")
    plt.ylabel("頻度")
    plt.savefig(os.path.join(out_dir, "email_body_length_histogram.png"))
    plt.close()


# メール本文の単語数のヒストグラムを保存する関数
def save_email_word_count_histogram(data: pd.DataFrame):
    plt.figure(figsize=(12, 6))
    sns.histplot(
        data=data,
        x="words",
        hue="label",
        kde=True,
        palette="coolwarm",
        bins=30,
        multiple="stack",
    )
    plt.title("メール本文の単語数のヒストグラム")
    plt.xlabel("メール本文の単語数")
    plt.ylabel("頻度")
    plt.savefig(os.path.join(out_dir, "email_body_word_count_histogram.png"))
    plt.close()


# 件名の長さのヒストグラムを保存する関数
def save_subject_length_histogram(data: pd.DataFrame):
    data["subject_length"] = data["subject"].str.len()
    plt.figure(figsize=(12, 6))
    sns.histplot(
        data=data,
        x="subject_length",
        hue="label",
        kde=True,
        palette="coolwarm",
        bins=30,
        multiple="stack",
    )
    plt.title("メール件名の長さのヒストグラム")
    plt.xlabel("メール件名の長さ")
    plt.ylabel("頻度")
    plt.savefig(os.path.join(out_dir, "email_subject_length_histogram.png"))
    plt.close()


def clean_word(word: str) -> str:
    return re.sub(r"([\W\s_]|[\x00-\x1F\x7F])+", "", word)


# メール本文で最も頻繁に出現する単語のトップ10を保存する関数
def save_top_frequent_words_in_body(data: pd.DataFrame):
    # 記号を取り除いた単語をカウント
    data["clean_counter"] = data["counter"].apply(
        lambda x: {clean_word(k): v for k, v in x.items()}
    )  # Counterでない場合は空辞書
    data["clean_counter"] = data["clean_counter"].apply(
        lambda x: collections.Counter(x)
    )

    # `label` ごとにメール本文の単語頻度を集計
    clean_counter_by_label = data.groupby("label")["clean_counter"].apply(
        lambda x: [word for sublist in x for word in sublist]
    )

    # それぞれの `label` ごとに単語の頻度をカウント
    top_words_by_label = {}
    for label, words in clean_counter_by_label.items():
        word_counter = collections.Counter(words)
        top_words_by_label[label] = word_counter.most_common(10)

    # 結果をデータフレームに変換
    top_words_list = []
    for label, top_words in top_words_by_label.items():
        for word, count in top_words:
            top_words_list.append([label, word, count])

    top_words_df = pd.DataFrame(top_words_list, columns=["label", "word", "count"])

    # グラフの描画
    plt.figure(figsize=(12, 6))
    sns.barplot(
        x="count",
        y="word",
        data=top_words_df,
        hue="label",
        palette="coolwarm",
        dodge=True,
    )
    plt.title("メール本文で最も頻繁に使われる単語上位10個")
    plt.xlabel("単語数")
    plt.ylabel("単語")
    plt.savefig(os.path.join(out_dir, "top_10_frequent_words_in_body.png"))
    plt.close()


# メール件名で最も頻繁に出現する単語のトップ10を保存する関数
def save_top_frequent_words_in_subject(data: pd.DataFrame):
    # 件名の単語を処理し、記号を取り除く
    subject_words = (
        data["subject"]
        .str.split()
        .apply(
            lambda x: [clean_word(word.lower()) for word in x]
        )  # 記号を取り除いて小文字化
    )

    # `label` ごとに件名の単語を分けてリストを作成
    data["subject_words_clean"] = subject_words
    subject_word_counter_by_label = data.groupby("label")["subject_words_clean"].apply(
        lambda x: [word for sublist in x for word in sublist]
    )

    # それぞれの `label` ごとに単語の頻度をカウント
    top_subject_words_by_label = {}
    for label, words in subject_word_counter_by_label.items():
        word_counter = collections.Counter(words)
        top_subject_words_by_label[label] = word_counter.most_common(10)

    # 結果をデータフレームに変換
    top_subject_words_list = []
    for label, top_words in top_subject_words_by_label.items():
        for word, count in top_words:
            top_subject_words_list.append([label, word, count])

    top_subject_df = pd.DataFrame(
        top_subject_words_list, columns=["label", "word", "count"]
    )

    # グラフの描画
    plt.figure(figsize=(12, 6))
    sns.barplot(
        x="count",
        y="word",
        data=top_subject_df,
        hue="label",
        palette="coolwarm",
        dodge=True,
    )
    plt.title("メール件名で最も頻繁に使われる単語上位10個")
    plt.xlabel("単語数")
    plt.ylabel("単語")
    plt.savefig(os.path.join(out_dir, "top_10_frequent_words_in_subject.png"))
    plt.close()


# 件名の長さと本文の長さの関係を保存する関数
def save_subject_vs_body_length(data: pd.DataFrame):
    plt.figure(figsize=(12, 6))
    sns.scatterplot(
        x=data["subject_length"],
        y=data["length"],
        hue=data["label"],  # labelをhueに指定して色分け
        palette="coolwarm",
    )
    plt.title("件名の長さと本文の長さの関係")
    plt.xlabel("件名の長さ")
    plt.ylabel("本文の長さ")
    plt.savefig(os.path.join(out_dir, "subject_vs_body_length.png"))
    plt.close()


# 件名の長さと本文の単語数の関係を保存する関数
def save_subject_vs_word_count_in_body(data: pd.DataFrame):
    plt.figure(figsize=(12, 6))
    sns.scatterplot(
        x=data["subject_length"],
        y=data["words"],
        hue=data["label"],
        palette="coolwarm",
    )
    plt.title("件名の長さと本文の単語数の関係")
    plt.xlabel("件名の長さ")
    plt.ylabel("本文の単語数")
    plt.savefig(os.path.join(out_dir, "subject_vs_word_count_in_body.png"))
    plt.close()

def multinomial_nb(test_data: pd.DataFrame, train_data: pd.DataFrame) -> pd.DataFrame:
    """Multinomial Naive Bayes を用いてスパム予測を行う関数"""
    vectorizer = CountVectorizer(stop_words="english")
    X_train, y_train = (
        vectorizer.fit_transform(train_data["body"]),
        train_data["label"],
    )
    model = MultinomialNB().fit(X_train, y_train)  # MultinomialNB を使用
    test_data["predicted_label"] = model.predict(
        vectorizer.transform(test_data["body"])
    )
    return test_data


def bernoulli_nb(test_data: pd.DataFrame, train_data: pd.DataFrame) -> pd.DataFrame:
    vectorizer = CountVectorizer(stop_words="english")
    X_train, y_train = (
        vectorizer.fit_transform(train_data["body"]),
        train_data["label"],
    )
    model = BernoulliNB().fit(X_train, y_train)
    test_data["predicted_label"] = model.predict(
        vectorizer.transform(test_data["body"])
    )
    return test_data


def save_guess_result_to_csv(predictions_df: pd.DataFrame, output_path: str) -> None:
    # predictions_df に 'filename' と 'predicted_label' 列が存在することを確認
    if (
        "filename" not in predictions_df.columns
        or "predicted_label" not in predictions_df.columns
    ):
        raise ValueError(
            "DataFrame must contain 'filename' and 'predicted_label' columns."
        )

    predictions_df = predictions_df[
        ["filename", "predicted_label"]
    ]  # 必要な列だけを抽出
    # DataFrame を CSV ファイルとして保存
    predictions_df.to_csv(output_path, index=False, encoding="utf-8", header=False)

    print(f"予測結果が {output_path} に保存されました。")


def save_all_graphs(data: pd.DataFrame):
    save_email_body_length_histogram(data)
    save_email_word_count_histogram(data)
    save_subject_length_histogram(data)
    save_top_frequent_words_in_body(data)
    save_top_frequent_words_in_subject(data)
    save_subject_vs_body_length(data)
    save_subject_vs_word_count_in_body(data)


def guess(traindata: pd.DataFrame, testdata: pd.DataFrame):
    for run in [
        bernoulli_nb,
        multinomial_nb
    ]:
        train = traindata.copy()
        test = testdata.copy()
        result = run(test, train)
        save_guess_result_to_csv(
            result, os.path.join(out_dir, f"guess_result_{run.__name__}.csv")
        )


def main() -> int:
    traindata = parse_mail(read_train_data())
    testdata = parse_mail(read_test_data())
    # show_info(traindata)
    # save_all_graphs(traindata)
    guess(traindata, testdata)
    return 0


if __name__ == "__main__":
    sys.exit(main())
