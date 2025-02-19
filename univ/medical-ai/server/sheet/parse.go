package sheet

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/jszwec/csvutil"
)

type TestResult struct {
	RawScore string `csv:"スコア"`
	Mail     string `csv:"メールアドレス"`
	Score    int
}

func TestResultFromCsv(csv []byte) ([]TestResult, error) {
	var res []TestResult

	if err := csvutil.Unmarshal(csv, &res); err != nil {
		return nil, err
	}

	for i, r := range res {
		score, err := parseScore(r.RawScore)
		if err != nil {
			return nil, err
		}
		res[i].Score = score
	}

	return res, nil
}

func TestResultFromUrl(url string) ([]TestResult, error) {
	csv, err := fetchCSV(url)
	if err != nil {
		return nil, err
	}

	return TestResultFromCsv([]byte(csv))
}

func parseScore(rawScore string) (int, error) {
	splited := strings.Split(rawScore, "/")
	if len(splited) != 2 {
		return 0, fmt.Errorf("invalid score format")
	}

	scoreStr := strings.TrimSpace(splited[0])
	maxStr := strings.TrimSpace(splited[1])

	score, err := strconv.Atoi(scoreStr)
	if err != nil {
		return 0, err
	}
	max, err := strconv.Atoi(maxStr)
	if err != nil {
		return 0, err
	}

	persent := float64(score) / float64(max) * 100
	return int(persent), nil
}
