package cmd

import (
	"strings"

	"github.com/Hayao0819/zash/go/shell"
	"github.com/spf13/cobra"
)

func runCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "run",
		Short: "Run a command",
		RunE: func(cmd *cobra.Command, args []string) error {
			arg := strings.Join(args, " ")
			if len(strings.TrimSpace(arg)) == 0 {
				return nil
			}

			s, err := shell.New()
			if err != nil {
				return err
			}
			if err := s.Run(arg); err != nil {
				return err
			}
			return nil
		},
		SilenceErrors: true,
		SilenceUsage:  true,
	}

	return cmd
}
