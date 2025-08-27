package executer

import (
	"fmt"
	"os"
	"syscall"

	"github.com/Hayao0819/nahi/futils"
)

type ExternalExecuter struct{}

func (ee *ExternalExecuter) Exec(argv []string, ioctx IOContext) (int, error) {
	if len(argv) == 0 {
		return 0, nil
	}

	abs, err := resolveExecPath(argv[0])
	if err != nil {
		return 127, fmt.Errorf("exec: %s: %w", argv[0], err)
	}

	if !futils.Exists(abs) {
		return 127, fmt.Errorf("%s: No such file or directory", abs)
	}

	attr := &os.ProcAttr{
		Files: ioctx.Files(),
		Env:   os.Environ(),
		Sys:   &syscall.SysProcAttr{},
	}

	process, err := os.StartProcess(abs, argv, attr)
	if err != nil {
		return 127, err
	}

	state, err := process.Wait()
	if err != nil {
		return 127, err
	}

	if state.Success() {
		return 0, nil
	}

	return state.ExitCode(), fmt.Errorf("%s: %s", abs, state.String())
}
