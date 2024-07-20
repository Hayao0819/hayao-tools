# Gistrge - Share binary file on Gist

GitHub Gistにバイナリファイルをアップロードして共有するためのツール

## 使い方

環境変数でGitHubのトークンを設定する

```bash
export GISTRGE_GITHUB_TOKEN='xxxxxxx'
```

新しいファイルをアップロードする

```bash
gistrge up -d ファイルの説明 ./1.txt ./2.png ...
```

Gistrgeによってアップロードされたファイルの一覧を取得する

```bash
gistrge list
```

ダウンロードは現在開発中です
