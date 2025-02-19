#!/bin/bash

set -euo pipefail

# 環境変数設定（必要に応じて変更）
API_KEY="your-mailgun-api-key"
DOMAIN="your-mailgun-domain"
TO_EMAIL="recipient@example.com"
FROM_EMAIL="sender@${DOMAIN}"
SUBJECT="集計結果"
SPREADSHEET_ID="your-sheet-id"

# 一時ファイル作成
CSV_FILE=$(mktemp)

# スクリプト終了時に一時ファイルを削除
cleanup() {
    rm -f "${CSV_FILE}"
}
trap cleanup EXIT

# スプレッドシートをCSVでダウンロード
download_csv() {
    local url="https://docs.google.com/spreadsheets/d/${SPREADSHEET_ID}/export?format=csv"
    curl -fsS -o "${CSV_FILE}" "${url}"
    if [[ ! -s "${CSV_FILE}" ]]; then
        echo "CSVのダウンロードに失敗しました。" >&2
        exit 1
    fi
}

# MailGunでHTMLメール送信
send_mailgun_email() {
    local html_content
    html_content="<html>
    <body>
        <h2>集計結果</h2>
        <table border='1'>
            <tr><th>Name</th><th>Content</th></tr>"
    while IFS=, read -r name content; do
        html_content+="<tr><td>${name}</td><td>${content}</td></tr>"
    done < <(tail -n +2 "${CSV_FILE}")
    html_content+="</table>
    </body>
    </html>"

    curl -fsS --user "api:${API_KEY}" \
        "https://api.mailgun.net/v3/${DOMAIN}/messages" \
        -F from="${FROM_EMAIL}" \
        -F to="${TO_EMAIL}" \
        -F subject="${SUBJECT}" \
        -F html="${html_content}"
}

# メイン処理
main() {
    download_csv
    send_mailgun_email
}

main
