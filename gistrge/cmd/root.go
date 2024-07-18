package cmd

import (
	"github.com/Hayao0819/Hayao-Tools/gistrge/env"
	"github.com/Hayao0819/Hayao-Tools/gistrge/mobra"
	"github.com/cockroachdb/errors"
	"github.com/spf13/cobra"
)

func root() *cobra.Command {
	root := mobra.New("gistrge").
		Short("gistrge is a CLI tool for using GitHub Gist as a storage").
		DisableCompletion().
		HideErrors().
		HideUsage().
		BindSubCmds(&Registory).
		PersistentPreRunE(func(cmd *cobra.Command, args []string) error {
			return env.Load()
		}).
		Cobra()

	return root
}

func Execute() error {
	if err := root().Execute(); err != nil {
		return errors.WithDetail(err, "failed to execute root command")
	}
	return nil
}
