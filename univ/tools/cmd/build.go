package cmd

import (
	"github.com/Hayao0819/Hayao-Tools/univ/tools/buildtools"
	"github.com/Hayao0819/Hayao-Tools/univ/tools/utils"
	"github.com/Hayao0819/nahi/cobrautils"
	"github.com/spf13/cobra"
)

func buildCmd() *cobra.Command {
	cmd := cobra.Command{
		Use:   "build",
		Short: "Build the codes",
		RunE: func(cmd *cobra.Command, args []string) error {
			srcDir, err := utils.GetSrcDir()
			if err != nil {
				return err
			}

			list, err := utils.GetSourceFiles(srcDir)
			if err != nil {
				return err
			}

			file, err := utils.SelectFile(list)
			if err != nil {
				return err
			}

			out := *file + ".out"

			return buildtools.Run(*file, out)
		},
	}
	return &cmd
}

func init() {
	cobrautils.RegisterSubCmd(buildCmd())
}
