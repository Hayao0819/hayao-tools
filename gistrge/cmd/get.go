package cmd

import (
	"encoding/json"

	"github.com/Hayao0819/Hayao-Tools/gistrge/gistrge"
	"github.com/Hayao0819/Hayao-Tools/gistrge/mobra"
	"github.com/Hayao0819/Hayao-Tools/gistrge/utils"
	"github.com/cockroachdb/errors"
	"github.com/spf13/cobra"
)

func GetCmd() *cobra.Command {
	target := ""
	user := ""
	onlyUrl := false
	rawContent := false
	rawJSON := false

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
			found, err := gists.Find(target)
			if err != nil {
				return errors.Wrap(err, "failed to find")
			}
			if found == nil {
				return errors.New("Specified gist not found")
			}

			// Output URL
			if onlyUrl {
				cmd.Println(found.GetFileURLFromGist())
				return nil
			}

			// Output raw content
			if rawContent || rawJSON {
				data, err := found.GetUploadData()
				if err != nil {
					return err
				}
				if rawContent {
					cmd.Println(data.Data)
				} else if rawJSON {
					json, err := json.Marshal(data)
					if err != nil {
						return err
					}
					cmd.Println(string(json))
				}

				return nil
			}

			// Decode base64 and extract tarball
			decoded, err := found.DecodeFile()
			if err != nil {
				return err
			}

			// Extract tarball

			_, err = utils.ExtractBytes(decoded)
			if err != nil {
				return err
			}

			return nil

		}).Cobra()

	cmd.Flags().StringVarP(&user, "user", "u", "", "GitHub user name")
	cmd.Flags().BoolVarP(&onlyUrl, "onlyurl", "o", false, "Output only URL")
	cmd.Flags().BoolVarP(&rawContent, "raw", "r", false, "Output raw content")
	cmd.Flags().BoolVarP(&rawJSON, "json", "j", false, "Output raw json")

	return cmd
}

func init() {
	Registory.Add(GetCmd())
}
