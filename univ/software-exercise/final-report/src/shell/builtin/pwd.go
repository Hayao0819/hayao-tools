package builtin

import (
	"fmt"
	"os"
)

var pwdCmd = internalCmd{
	Name: "pwd",
	Func: func(args []string, files []*os.File) Result {
		if len(args) > 0 {
			// return fmt.Errorf("exit: too many arguments")
			return Result{
				err:      fmt.Errorf("pwd: too many arguments"),
				exitcode: 1,
			}
		}

		wd, err := os.Getwd()
		if err != nil {
			// return fmt.Errorf("pwd: %s", err)
			return Result{
				err:      fmt.Errorf("pwd: %s", err),
				exitcode: 1,
			}
		}
		// fmt.Fprintln(e.TTY.Output(), wd)
		// e.Puts(wd, "\n")
		fmt.Fprintln(files[1], wd)

		return Result{
			err:      nil,
			exitcode: 0,
		}

	},
}

func init() {
	Cmds = append(Cmds, pwdCmd)
}
