package buildtools

import "github.com/Hayao0819/nahi/exutils"

// targetは.cのファイル
func buildC(target string, out string) error {
	cmd := exutils.CommandWithStdio("gcc", "-o", out, target)
	return cmd.Run()
}
