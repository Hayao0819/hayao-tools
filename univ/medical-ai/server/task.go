package main

import (
	"fmt"
	"os"
	"time"

	"github.com/Hayao0819/hayao-tools/univ/medical-ai/server/sendmail"
	"github.com/Hayao0819/hayao-tools/univ/medical-ai/server/sheet"
	"github.com/samber/lo"
)

func getTestResultsByMail(list [][]sheet.TestResult, mail string) []sheet.TestResult {
	var res []sheet.TestResult
	for _, r := range list {
		for _, rr := range r {
			if rr.Mail == mail {
				res = append(res, rr)
			}
		}
	}
	return res
}

func getTotalAverageScore(list []sheet.TestResult) int {
	var total int
	for _, r := range list {
		total += r.Score
	}
	return total / len(list)
}

func sendMailTask(date time.Time, r *ScheduleRequest) func() {
	return func() {
		var res [][]sheet.TestResult = [][]sheet.TestResult{}
		for _, s := range r.SpreadsheetURL {
			r, err := sheet.TestResultFromUrl(s)
			if err != nil {
				fmt.Fprintln(os.Stderr, err)
				continue
			}
			res = append(res, r)
		}

		mails := lo.Uniq(
			lo.Flatten(
				lo.Map(res, func(item []sheet.TestResult, i int) []string {
					return lo.Map(item, func(r sheet.TestResult, i int) string {
						return r.Mail
					})
				})))

		var avgs map[string]int = map[string]int{}
		for _, m := range mails {
			results := getTestResultsByMail(res, m)
			if len(results) == 0 {
				fmt.Printf("No test results found for %s\n", m)
				continue
			}

			avg := getTotalAverageScore(results)
			avgs[m] = avg
		}

		fmt.Println(avgs)

		mail := createReportMail(date, avgs, r.SendTo, r.PassingScore)
		if err := mail.Send(); err != nil {
			fmt.Fprintln(os.Stderr, err)
		}

	}
}

func createReportMail(date time.Time, result map[string]int, to string, passingScore int) sendmail.Mail {
	body := ""
	for mail, score := range result {
		if score < passingScore {
			body += fmt.Sprintf("%s: %d (不合格)\n", mail, score)
			continue
		}
		body += fmt.Sprintf("%s: %d\n", mail, score)
	}

	sendmail := sendmail.Mail{
		User:    "gform-notify",
		Domain:  "mg.hayao0819.com",
		Subject: fmt.Sprintf("%sのテスト結果", date.Format("2006-01-02")),
		Body:    body,
		To:      []string{to},
	}

	return sendmail
}
