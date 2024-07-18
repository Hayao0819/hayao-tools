package cmd

import (
	"errors"

	"github.com/Hayao0819/Hayao-Tools/gistrge/gistrge"
	"github.com/Hayao0819/nahi/mobra"
	"github.com/spf13/cobra"
)

func GetCmd() *cobra.Command {
	target := ""
	user := ""
	onlyUrl := false

	cmd := mobra.
		New("get").
		PreRunE(func(cmd *cobra.Command, args []string) error {
			target = args[0]
			if target == "" {
				return errors.New("target is required")
			}
			return nil
		}).
		RunE(func(cmd *cobra.Command, args []string) error {
			gists, err := gistrge.GetGistrges(user)
			if err != nil {
				return err
			}

			found, err := gistrge.Find(gists, target)
			if err != nil {
				return err
			}
			if found == nil {
				return errors.New("not found")
			}

			if onlyUrl {
				cmd.Println(gistrge.GetFileURL(found))
				return nil
			}

			content, err := gistrge.GetContent(found)
			if err != nil {
				return err
			}
			cmd.Println(content)
			return nil

		}).Cobra()

	cmd.Flags().StringVarP(&user, "user", "u", "", "GitHub user name")
	cmd.Flags().BoolVarP(&onlyUrl, "onlyurl", "o", false, "Output only URL")

	return cmd
}

func init() {
	Registory.Add(GetCmd())
}
