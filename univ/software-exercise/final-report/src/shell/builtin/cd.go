package builtin

import (
	"fmt"
	"os"
	"strings"

	"github.com/Hayao0819/zash/go/internal/logmgr"
)

var cdLastDir string

var cdCmd = internalCmd{
	Name: "cd",
	Func: func(args []string, files []*os.File) Result {
		do := func(dir string) Result {
			cdLastDir, _ = os.Getwd()
			logmgr.Shell().Debug("cd", "lastDir", cdLastDir, "to", dir)
			if err := os.Chdir(dir); err != nil {
				// return fmt.Errorf("cd: %s", err)
				return Result{
					exitcode: 1,
					err:      fmt.Errorf("cd: %s", err),
				}
			}
			return Result{
				exitcode: 0,
			}

		}

		if len(args) == 0 {
			logmgr.Shell().Debug("cd: no arguments", "home", os.Getenv("HOME"))
			return do(os.Getenv("HOME"))
		} else if len(args) > 1 {
			// return fmt.Errorf("cd: too many arguments")
			logmgr.Shell().Error("cd: too many arguments", "args", strings.Join(args, " "))
			return Result{
				exitcode: 1,
				err:      fmt.Errorf("cd: too many arguments"),
			}
		} else if args[0] == "-" {
			if cdLastDir == "" {
				logmgr.Shell().Error("cd: no previous directory", "lastDir", cdLastDir)
				return Result{
					exitcode: 1,
					err:      fmt.Errorf("cd: no previous directory"),
				}
			}
			fmt.Fprintln(files[1], cdLastDir)
			return do(cdLastDir)
		} else {
			return do(args[0])
		}
	},
}

func init() {
	Cmds = append(Cmds, cdCmd)
}
