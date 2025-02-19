package main

import (
	"log"
	"time"

	"github.com/go-co-op/gocron/v2"
)

var ns gocron.Scheduler

func init() {
	var err error
	jst, err := time.LoadLocation("Asia/Tokyo")
	if err != nil {
		log.Fatal(err)
		return
	}

	ns, err = gocron.NewScheduler(gocron.WithLocation(jst))
	if err != nil {
		log.Fatal(err)
		return
	}

	ns.Start()
}
