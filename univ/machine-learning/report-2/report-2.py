#!/usr/bin/env python3
import sys
import pandas as pd
import os
import glob
import os.path as path
import collections
import matplotlib.pyplot as plt
import seaborn as sns
import japanize_matplotlib # type: ignore
import re

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
    # print(test_files)
    return test_files


def parse_mail(data: pd.DataFrame) -> pd.DataFrame:
    data["subject"] = data["mail"].str.split("\n").str[0].replace(r"^Subject:\s*", "", regex=True)
    data["body"] = data["mail"].str.split("\n").str[1:].str.join(" ")
    data["counter"] = data["body"].str.split(" ").apply(collections.Counter)
    data["length"] = data["body"].str.len()
    data["words"] = data["counter"].apply(lambda x: sum(x.values()))
    return data


def show_info(data: pd.DataFrame):
    types = data.dtypes
    print(types)


# 'out' ディレクトリが存在しない場合は作成
if not os.path.exists("out"):
    os.makedirs("out")


# メール本文の長さのヒストグラムを保存する関数
def save_email_body_length_histogram(data: pd.DataFrame):
    plt.figure(figsize=(12, 6))
    sns.histplot(data["length"], kde=True, color="blue", bins=30)
    plt.title("メール本文の長さのヒストグラム")
    plt.xlabel("メール本文の長さ")
    plt.ylabel("頻度")
    plt.savefig(os.path.join(out_dir, "email_body_length_histogram.png"))
    plt.close()


# メール本文の単語数のヒストグラムを保存する関数
def save_email_word_count_histogram(data: pd.DataFrame):
    plt.figure(figsize=(12, 6))
    sns.histplot(data["words"], kde=True, color="green", bins=30)
    plt.title("メール本文の単語数のヒストグラム")
    plt.xlabel("メール本文の単語数")
    plt.ylabel("頻度")
    plt.savefig(os.path.join(out_dir, "email_body_word_count_histogram.png"))
    plt.close()


# 件名の長さのヒストグラムを保存する関数
def save_subject_length_histogram(data: pd.DataFrame):
    data["subject_length"] = data["subject"].str.len()
    plt.figure(figsize=(12, 6))
    sns.histplot(data["subject_length"], kde=True, color="orange", bins=30)
    plt.title("メール件名の長さのヒストグラム")
    plt.xlabel("メール件名の長さ")
    plt.ylabel("頻度")
    plt.savefig(os.path.join(out_dir, "email_subject_length_histogram.png"))
    plt.close()


def clean_word(word:str) -> str:
    return re.sub(r'([\W\s_]|[\x00-\x1F\x7F])+', '', word)

# メール本文で最も頻繁に出現する単語のトップ10を保存する関数
def save_top_frequent_words_in_body(data: pd.DataFrame):
    # 記号を取り除いた単語をカウント
    top_words = (
        data["counter"]
        .apply(lambda x: {clean_word(k): v for k, v in x.items()})  # Counterでない場合は空辞書
        .apply(lambda x: collections.Counter(x))
        .apply(lambda x: x.most_common(1) if x else [("", 0)])  # 空のCounterの場合でも処理を続行
        .apply(lambda x: x[0] if x else ("", 0))
    )
    
    top_words_df = pd.DataFrame(top_words.tolist(), columns=["word", "count"])

    # 記号を取り除いた単語のみで集計
    top_words_df = top_words_df.groupby("word")["count"].sum().reset_index()
    top_words_df = top_words_df.sort_values(by="count", ascending=False).head(10)

    plt.figure(figsize=(12, 6))
    sns.barplot(x="count", y="word", data=top_words_df, hue="word", palette="viridis", legend=False)
    plt.title("メール本文で最も頻繁に使われる単語上位10個）")
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
        .apply(lambda x: [clean_word(word.lower()) for word in x])  # 記号を取り除いて小文字化
    )
    
    subject_words_flat = [word for sublist in subject_words for word in sublist]
    subject_word_counter = collections.Counter(subject_words_flat)
    top_subject_words = subject_word_counter.most_common(10)

    top_subject_df = pd.DataFrame(top_subject_words, columns=["word", "count"])

    plt.figure(figsize=(12, 6))
    sns.barplot(x="count", y="word", data=top_subject_df, hue="word", palette="plasma", legend=False)
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
        hue=data["subject_length"],
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
        hue=data["subject_length"],
        palette="coolwarm",
    )
    plt.title("件名の長さと本文の単語数の関係")
    plt.xlabel("件名の長さ")
    plt.ylabel("本文の単語数")
    plt.savefig(os.path.join(out_dir, "subject_vs_word_count_in_body.png"))
    plt.close()

def save_all_graphs(data: pd.DataFrame):
    save_email_body_length_histogram(data)
    save_email_word_count_histogram(data)
    save_subject_length_histogram(data)
    save_top_frequent_words_in_body(data)
    save_top_frequent_words_in_subject(data)
    save_subject_vs_body_length(data)
    save_subject_vs_word_count_in_body(data)


def main() -> int:
    traindata = parse_mail(read_train_data())
    testdata = parse_mail(read_test_data())
    # print(traindata["subject"])
    # show_info(traindata)
    save_all_graphs(traindata)
    return 0


if __name__ == "__main__":
    sys.exit(main())
