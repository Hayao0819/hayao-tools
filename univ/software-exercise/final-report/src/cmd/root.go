package cmd

import (
	"github.com/Hayao0819/zash/go/internal/logmgr"
	"github.com/Hayao0819/zash/go/shell"
	"github.com/spf13/cobra"
)

func rootCmd() *cobra.Command {
	var optCmdStr string
	var optDebug bool
	cmd := &cobra.Command{
		Use:   "zash [script_file]",
		Short: "Zash is a shell written in Go.",
		Args:  cobra.MaximumNArgs(1),
		PersistentPreRun: func(cmd *cobra.Command, args []string) {
			if optDebug {
				logmgr.EnableAll()
				logmgr.Shell().Info("debug mode enabled")
			}
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			if optCmdStr != "" {
				rc := runCmd()
				rc.SetArgs([]string{optCmdStr})
				return rc.Execute()
			}

			// ファイル引数がある場合はスクリプトファイルとして実行
			if len(args) > 0 {
				s, err := shell.New()
				if err != nil {
					return err
				}
				return s.RunFile(args[0])
			}

			s, err := shell.New()
			if err != nil {
				return err
			}

			s.StartInteractive()
			return nil
		},
		SilenceErrors: true,
		SilenceUsage:  true,
	}
	// cmd.Flags().StringP("command", "c", "", "command to execute")
	cmd.Flags().StringVarP(&optCmdStr, "command", "c", "", "command to execute")
	cmd.Flags().BoolVarP(&optDebug, "debug", "d", false, "debug mode")

	cmd.AddCommand(runCmd())

	return cmd
}
