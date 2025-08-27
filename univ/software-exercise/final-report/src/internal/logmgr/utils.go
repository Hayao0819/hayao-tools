package logmgr

import (
	"log/slog"

	"github.com/m-mizutani/clog"
)

func colorHandler() slog.Handler {
	return clog.New(clog.WithColor(true), clog.WithLevel(slog.LevelDebug))
}

func nopHandler() slog.Handler {
	return clog.New(clog.WithLevel(slog.Level(100)))
}

func categorizedColorLogger(c string) *slog.Logger {
	return slog.New(colorHandler()).With("category", c)
}
