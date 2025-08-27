package logmgr

import (
	"log/slog"
)

type Loggers map[string]*slog.Logger

func (l *Loggers) Get(category string) *slog.Logger {
	if logger, ok := (*l)[category]; ok {
		return logger
	}
	return slog.New(nopHandler())
}

func (l *Loggers) Set(category string) {
	if _, ok := (*l)[category]; ok {
		return
	}

	(*l)[category] = categorizedColorLogger(category)
}
func (l *Loggers) Disable(category string) {
	delete(*l, category)
}
