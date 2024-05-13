package buildtools

import "github.com/Hayao0819/nahi/exutils"

func buildGo(target string, out string) error {
	cmd := exutils.CommandWithStdio("go", "build", "-o", out, target)
	return cmd.Run()
}
