package main

import (
	"fmt"
	"os"

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

func sendMailTask(sheets []string) func() {
	return func() {
		var res [][]sheet.TestResult = [][]sheet.TestResult{}
		for _, s := range sheets {
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

	}
}
