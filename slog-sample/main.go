package main

import (
	"log/slog"
	"os"

	"github.com/m-mizutani/clog"
	slogmulti "github.com/samber/slog-multi"
)

func coloredLogger() slog.Handler {
	handler := clog.New(clog.WithColor(true))
	return slog.Handler(handler)
}

func fileLogger(f *os.File) slog.Handler {
	return slog.Handler(slog.NewTextHandler(f, nil))
}

func handleError(err error) {
	if err != nil {
		panic(err)
	}
}

func main() {
	f, err := os.Create("log.txt")
	handleError(err)
	defer f.Close()

	singleHandler := slogmulti.Fanout(
		coloredLogger(),
		fileLogger(f),
	)

	logger := slog.New(singleHandler)
	slog.SetDefault(logger)

	slog.Info("Hello, world")
	slog.Warn("Hello, world")
	slog.Error("Hello, world")
}
