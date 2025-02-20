package main

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-co-op/gocron/v2"
)

// リクエストデータ構造体
type ScheduleRequest struct {
	SendTo         string   `json:"send_to"`
	DateTime       string   `json:"datetime"`
	SpreadsheetURL []string `json:"spreadsheet_url"`
	PassingScore   int      `json:"passing_score"`
}

func scheduleHandler(c *gin.Context) {
	var req ScheduleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	date, err := time.Parse(time.RFC3339, req.DateTime)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err = ns.NewJob(
		gocron.OneTimeJob(gocron.OneTimeJobStartDateTime(date)),
		gocron.NewTask(sendMailTask(date, &req)),
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "scheduled"})

}

func pingHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "pong"})
}
