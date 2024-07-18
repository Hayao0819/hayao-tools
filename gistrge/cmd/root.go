package cmd

import (
	"github.com/Hayao0819/nahi/mobra"
	"github.com/spf13/cobra"
)

func root() *cobra.Command {
	return mobra.New("gistrge").
		Short("gistrge is a CLI tool for using GitHub Gist as a storage").
		DisableCompletion().
		HideUsage().
		BindSubCmds(&Registory).
		Cobra()
}

func Execute() error {
	return root().Execute()
}
