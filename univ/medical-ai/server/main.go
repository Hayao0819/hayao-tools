package main

import (
	"log"

	"github.com/gin-gonic/gin"
)

// リクエストデータ構造体
type ScheduleRequest struct {
	DateTime       string `json:"datetime"`
	SpreadsheetURL string `json:"spreadsheet_url"`
}

func startServer() {
	r := gin.Default()
	r.POST("/schedule", scheduleEmail)

	// サーバ起動
	port := "8080"
	log.Printf("Server running on port %s...", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}

func main() {
	sendMailTask(
		[]string{"https://docs.google.com/spreadsheets/d/1OUnzvpROWT8hL8nlc0vfXtQqTcLxty-5Lpd2kbFkCwQ/edit?gid=1075438636#gid=1075438636"},
	)()
}
