package builtin

import (
	"os"
	"strconv"
)

var exitCmd = internalCmd{
	Name: "exit",
	Func: func(args []string, files []*os.File) Result {
		exitCode := 0
		if len(args) > 1 {
			if code, err := strconv.Atoi(args[1]); err == nil {
				exitCode = code
			}
		}
		os.Exit(exitCode)
		return Result{
			exitcode: exitCode,
		}
	},
}

func init() {
	Cmds = append(Cmds, exitCmd)
}
