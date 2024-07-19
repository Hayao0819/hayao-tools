package cmd

import (
	"encoding/base64"

	"github.com/Hayao0819/Hayao-Tools/gistrge/gistrge"
	"github.com/Hayao0819/Hayao-Tools/gistrge/mobra"
	"github.com/cockroachdb/errors"
	"github.com/spf13/cobra"
)

func GetCmd() *cobra.Command {
	target := ""
	user := ""
	onlyUrl := false
	rawContent := false

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
			// Get all gists
			gists, err := gistrge.GetGistrges(user)
			if err != nil {
				return err
			}

			// Find target gist
			found, err := gistrge.Find(gists, target)
			if err != nil {
				return errors.Wrap(err, "failed to find")
			}
			if found == nil {
				return errors.New("not found")
			}

			// Output URL
			if onlyUrl {
				cmd.Println(gistrge.GetFileURL(found))
				return nil
			}

			// Get content
			content, err := gistrge.GetContent(found)
			if err != nil {
				return err
			}

			// Output raw content
			if rawContent {
				cmd.Println(content)
				return nil
			}

			// Decode base64 and extract tarball
			_, err = base64.StdEncoding.DecodeString(content)
			if err != nil {
				return errors.Wrap(err, "failed to decode base64")
			}

			return nil

		}).Cobra()

	cmd.Flags().StringVarP(&user, "user", "u", "", "GitHub user name")
	cmd.Flags().BoolVarP(&onlyUrl, "onlyurl", "o", false, "Output only URL")
	cmd.Flags().BoolVarP(&rawContent, "raw", "r", false, "Output raw content")

	return cmd
}

func init() {
	Registory.Add(GetCmd())
}
