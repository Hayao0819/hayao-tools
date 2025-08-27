package cmd

import "log/slog"

func Execute() error {
	if err := rootCmd().Execute(); err != nil {
		slog.Error("Error", "msg", err)
		return err
	}
	return nil
}
