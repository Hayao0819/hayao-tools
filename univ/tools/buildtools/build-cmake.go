package buildtools

import "github.com/Hayao0819/nahi/exutils"

// targetはCMakeLists.txtがあるディレクトリ
func buildCmake(target string) error {
	cmd := exutils.CommandWithStdio("cmake", target)
	return cmd.Run()
}
