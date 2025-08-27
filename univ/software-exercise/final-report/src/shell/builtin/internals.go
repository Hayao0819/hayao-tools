package builtin

import (
	"fmt"
	"os"
)

type internalCmd struct {
	Name string
	Func func(args []string, files []*os.File) Result
	// State map[string]any
}

type InternalCmds []internalCmd

var Cmds = InternalCmds{}

func (ic *InternalCmds) Get(name string) *internalCmd {
	for _, cmd := range *ic {
		if cmd.Name == name {
			return &cmd
		}
	}
	return nil
}

func (ic *InternalCmds) Run(name string, args []string, files []*os.File) Result {
	cmd := ic.Get(name)
	if cmd == nil {
		return Result{
			err:      fmt.Errorf("%s: command not found", name),
			exitcode: 127,
		}
	}
	if files == nil{
		panic("files is nil")
	}
	return cmd.Func(args, files)

}
