package cmd

import (
	"github.com/Hayao0819/Hayao-Tools/gistrge/env"
	"github.com/Hayao0819/Hayao-Tools/gistrge/mobra"
	"github.com/Hayao0819/Hayao-Tools/gistrge/utils"
	"github.com/spf13/cobra"
)

func DebugCmd() *cobra.Command {
	return mobra.New("debug").
		RunE(func(cmd *cobra.Command, args []string) error {
			conf := env.Config()
			cmd.Printf("%+v\n", utils.JSON(conf))
			return nil
		}).Cobra()
}

func init() {
	Registory.Add(DebugCmd())
}
