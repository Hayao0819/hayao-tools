package cmd

import (
	"os"
	"path"
	"path/filepath"

	"github.com/Hayao0819/Hayao-Tools/univ/tools/buildtools"
	"github.com/Hayao0819/Hayao-Tools/univ/tools/utils"
	"github.com/Hayao0819/nahi/cobrautils"
	"github.com/Hayao0819/nahi/exutils"
	"github.com/spf13/cobra"
)

func runCmd() *cobra.Command {
	cmd := cobra.Command{
		Use:   "run",
		Short: "Run the codes",
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

			out := path.Join(os.TempDir(), filepath.Base(*file)+".out")
			if err := buildtools.Run(*file, out); err != nil {
				return err
			}

			if err := os.Chmod(out, 0755); err != nil {
				return err
			}

			if err := exutils.CommandWithStdio(out).Run(); err != nil {
				return err
			}

			if err := os.Remove(out); err != nil {
				return err
			}

			return nil
		},
	}
	return &cmd
}

func init() {
	cobrautils.AddSubCmds(runCmd())
}
