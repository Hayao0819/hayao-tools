package builtin

import (
	"fmt"
	"os"

	cowsay "github.com/Code-Hex/Neo-cowsay/v2"
)

var cowsayCmd = internalCmd{
	Name: "cowsay",
	Func: func(args []string, files []*os.File) Result {
		if len(args) == 0 {
			return Result{
				err:      nil,
				exitcode: 0,
			}
		}

		s, err := cowsay.Say(args[0], cowsay.Type("default"))
		if err != nil {
			return Result{
				err:      err,
				exitcode: 1,
			}
		}

		fmt.Fprintln(files[1], s)
		return Result{
			err:      nil,
			exitcode: 0,
		}
	},
}

func init() {
	Cmds = append(Cmds, cowsayCmd)
}
