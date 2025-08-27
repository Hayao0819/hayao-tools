package builtin

import (
	"fmt"
	"os"
	"os/exec"
)

var typeCmd = internalCmd{
	Name: "type",
	Func: func(args []string, files []*os.File) Result {

		if len(args) == 0 {
			return Result{}
		}
		for _, arg := range args {
			if Cmds.Get(arg) != nil {
				// t.Write([]byte("internal command\n"))
				// fmt.Fprintln(t.Output(), "internal command")
				fmt.Fprintf(files[1], "internal command: %s\n", arg)
				continue
			}

			p, err := exec.LookPath(arg)
			if err == nil {
				// fmt.Fprintf(t.Output(), "external command: %s\n", p)
				fmt.Fprintf(files[1], "external command: %s\n", p)
				continue
			}
			// return fmt.Errorf("type: %s: not found", arg)
			fmt.Fprintf(files[2], "type: %s: not found\n", arg)
			return Result{
				err:      nil,
				exitcode: 1,
			}
		}
		return Result{
			exitcode: 0,
		}

	},
}

func init() {
	Cmds = append(Cmds, typeCmd)
}
