package sheet

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
)

type SpreadsheetUrl struct {
	Id  string
	Gid string
}

func (s *SpreadsheetUrl) String() string {
	return fmt.Sprintf("https://docs.google.com/spreadsheets/d/%s/export?format=csv", s.Id)
}

func parseSpreadsheetUrl(rawURL string) (*SpreadsheetUrl, error) {
	u, err := url.Parse(rawURL)
	if err != nil {
		return nil, err
	}

	if u.Host != "docs.google.com" || !strings.Contains(u.Path, "/spreadsheets/d/") {
		return nil, fmt.Errorf("invalid Google Spreadsheet URL")
	}

	id := strings.Split(u.Path, "/")[3]

	q, err := url.ParseQuery(u.RawQuery)
	if err != nil {
		return nil, err
	}
	gid := q.Get("gid")

	s := SpreadsheetUrl{
		Id:  id,
		Gid: gid,
	}

	return &s, nil
}

// fetchCSV はGoogleスプレッドシートのURLを受け取り、CSVデータを取得する
func fetchCSV(spreadsheetURL string) ([]byte, error) {
	// スプレッドシートURLを解析
	s, err := parseSpreadsheetUrl(spreadsheetURL)
	if err != nil {
		return nil, err
	}

	// CSVダウンロードURLを生成
	csvURL := s.String()

	// HTTPリクエストを送信
	resp, err := http.Get(csvURL)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// ステータスコードチェック
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("failed to fetch CSV: status %d", resp.StatusCode)
	}

	// レスポンスボディを読み取る
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return body, nil
}
