package main

import (
	"time"

	"github.com/araddon/dateparse"
	"github.com/spf13/cobra"
)

// var reg cobrautils.Registory

func rootCmd() *cobra.Command {
	dateStr := ""
	sheets := []string{}
	mailAddr := ""
	var parsedDate time.Time
	cmd := cobra.Command{
		Use:  "gform-notify [date] [sheets...]",
		Args: cobra.MinimumNArgs(2),
		PreRunE: func(cmd *cobra.Command, args []string) error {
			dateStr = args[0]
			mailAddr = args[1]
			sheets = args[2:]

			var err error

			parsedDate, err = dateparse.ParseLocal(dateStr)
			if err != nil {
				return err
			}

			return nil
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			client := NewFormNotifyClient("http://localhost:8080")
			if err := client.Notify(parsedDate, sheets, mailAddr); err != nil {
				return err
			}
			return nil
		},
	}

	return &cmd
}
