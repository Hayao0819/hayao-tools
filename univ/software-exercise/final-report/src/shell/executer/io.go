package executer

import (
	"fmt"
	"os"
)

func NewDefaultIO() *IOContext {
	return &IOContext{
		Stdin:  os.Stdin,
		Stdout: os.Stdout,
		Stderr: os.Stderr,
	}
}

// stdin, stdout, stderr のセットを抽象化
type IOContext struct {
	Stdin  *os.File
	Stdout *os.File
	Stderr *os.File

	// 内部管理用 (閉じる必要があるファイル)
	closers []*os.File
}

func (io *IOContext) Files() []*os.File {
	return []*os.File{io.Stdin, io.Stdout, io.Stderr}
}

func (io *IOContext) Redirect(op, file string) error {
	switch op {
	case "<":
		f, err := os.Open(file)
		if err != nil {
			return fmt.Errorf("failed to open %s: %w", file, err)
		}
		io.Stdin = f
		io.closers = append(io.closers, f)

	case ">":
		f, err := os.OpenFile(file, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
		if err != nil {
			return fmt.Errorf("failed to open %s: %w", file, err)
		}
		io.Stdout = f
		io.closers = append(io.closers, f)

	default:
		return fmt.Errorf("unknown redirection operator: %s", op)
	}
	return nil
}

func (io *IOContext) PipeTo(next *IOContext) error {
	r, w, err := os.Pipe()
	if err != nil {
		return err
	}

	io.Stdout = w
	next.Stdin = r

	io.closers = append(io.closers, w)
	next.closers = append(next.closers, r)

	return nil
}
