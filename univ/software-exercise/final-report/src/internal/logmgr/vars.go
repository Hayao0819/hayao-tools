package logmgr

import (
	"log/slog"
)

var defaultLoggers Loggers

func Enable(cs ...string) {
	if defaultLoggers == nil {
		defaultLoggers = Loggers{}
	}
	for _, c := range cs {
		defaultLoggers.Set(c)
	}
}

func Disable(cs ...string) {
	if defaultLoggers == nil {
		defaultLoggers = Loggers{}
	}
	for _, c := range cs {
		defaultLoggers.Disable(c)
	}
}

func EnableAll() {
	if defaultLoggers == nil {
		defaultLoggers = Loggers{}
	}
	for _, c := range []string{"shell", "lexer", "parser", "executor", "cmd", "cmdexec"} {
		defaultLoggers.Set(c)
	}
}

// IsEnabled returns true if the specified category is enabled
func IsEnabled(category string) bool {
	if defaultLoggers == nil {
		return false
	}
	_, ok := defaultLoggers[category]
	return ok
}

var Shell = func() *slog.Logger { return defaultLoggers.Get("shell") }
var Lexer = func() *slog.Logger { return defaultLoggers.Get("lexer") }
var Parser = func() *slog.Logger { return defaultLoggers.Get("parser") }
var Executor = func() *slog.Logger { return defaultLoggers.Get("executor") }
var Cmd = func() *slog.Logger { return defaultLoggers.Get("cmd") }
var CmdExec = func() *slog.Logger { return defaultLoggers.Get("cmdexec") }
