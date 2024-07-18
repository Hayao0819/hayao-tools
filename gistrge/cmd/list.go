package cmd

import (
	"github.com/Hayao0819/Hayao-Tools/gistrge/gistrge"
	"github.com/Hayao0819/nahi/mobra"
	"github.com/samber/lo"
	"github.com/spf13/cobra"
)

func ListCmd() *cobra.Command {

	user := ""

	cmd := mobra.
		New("list").
		RunE(func(cmd *cobra.Command, args []string) error {
			gists, err := gistrge.GetGistrges(user)
			if err != nil {
				return err
			}

			output := lo.Map(gists, func(item *gistrge.Gistrge, index int) string {
				return item.Description
			})

			lo.ForEach(output, func(item string, index int) {
				cmd.Println(item)
			})
			return nil
		}).
		Cobra()
	cmd.Flags().StringVarP(&user, "user", "u", "", "GitHub user name")

	return cmd
}

func init() {
	Registory.Add(ListCmd())
}
