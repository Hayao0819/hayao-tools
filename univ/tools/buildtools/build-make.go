package buildtools

import "github.com/Hayao0819/nahi/exutils"

func buildMake(target string) error {
	cmd := exutils.CommandWithStdio("make", "-C", target)
	return cmd.Run()
}
