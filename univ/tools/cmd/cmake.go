package cmd

import (
	"github.com/Hayao0819/nahi/cobrautils"
	"github.com/spf13/cobra"
)

func cmakeCmd() *cobra.Command {
	cmd := cobra.Command{
		Use:   "cmake",
		Short: "Generate CMakeLists.txt",
		RunE: func(cmd *cobra.Command, args []string) error {

			return nil

			//return cmake.Run()
		},
	}
	return &cmd
}

func init() {
	cobrautils.RegisterSubCmd(cmakeCmd())
}
