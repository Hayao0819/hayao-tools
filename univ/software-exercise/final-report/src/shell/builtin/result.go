package builtin

type Result struct {
	err      error
	exitcode int
}

func (r Result) Error() error {
	if r.err != nil {
		return r.err
	}
	return nil
}

func (r Result) ExitCode() int {
	if r.err != nil {
		return 1
	}
	return r.exitcode
}
