package cmd

import (
	"log/slog"
	"strings"

	"github.com/Hayao0819/Hayao-Tools/gistrge/gistrge"
	"github.com/Hayao0819/Hayao-Tools/gistrge/mobra"
	"github.com/Hayao0819/nahi/futils"
	"github.com/cockroachdb/errors"
	"github.com/samber/lo"
	"github.com/spf13/cobra"
)

func UpCmd() *cobra.Command {

	paths := []string{}
	description := ""

	cmd := mobra.New("up").
		Short("Upload a file to GitHub Gist").
		PreRunE(func(cmd *cobra.Command, args []string) error {

			paths = lo.Filter(args, func(item string, _ int) bool {
				if futils.Exists(item) {
					return true
				} else {
					slog.Warn("File not found", "file", item)
					return false
				}
			})

			if strings.TrimSpace(description) == "" {
				slog.Warn("Description is required")
				return errors.New("description is required")
			}

			return nil
		}).
		RunE(func(cmd *cobra.Command, args []string) error {

			newGistrge, err := gistrge.FromFiles("Gistrge: "+description, paths...)
			if err != nil {
				return errors.Wrap(err, "failed to create new gistrge")
			}

			slog.Info("Uploading...")

			if err := newGistrge.CreateNewGist(); err != nil {
				return errors.Wrap(err, "failed to create gist")
			}

			return nil
		}).
		Cobra()

	cmd.Flags().StringVarP(&description, "description", "d", "", "Description of the Gist")

	return cmd
}

func init() {
	Registory.Add(UpCmd())
}
