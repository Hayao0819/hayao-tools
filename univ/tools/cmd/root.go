package cmd

import (
	"github.com/Hayao0819/nahi/cobrautils"
	"github.com/spf13/cobra"
)

func root() *cobra.Command {
	root := cobra.Command{
		Use:           "univ",
		Short:         "univ is a tool for manage codes for univ class",
		SilenceErrors: true,
		SilenceUsage:  true,
	}

	cobrautils.BindSubCmds(&root)
	return &root
}

func Execute() error {
	rootCmd := root()
	if err := rootCmd.Execute(); err != nil {
		return err
	}
	return nil
}
