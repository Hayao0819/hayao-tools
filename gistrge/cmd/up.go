package cmd

import (
	"bytes"
	"context"
	"encoding/base64"
	"log/slog"

	"github.com/Hayao0819/Hayao-Tools/gistrge/env"
	"github.com/Hayao0819/Hayao-Tools/gistrge/gist"
	"github.com/Hayao0819/Hayao-Tools/gistrge/mobra"
	"github.com/Hayao0819/nahi/futils"
	"github.com/google/go-github/v63/github"
	"github.com/mholt/archiver/v4"
	"github.com/pkg/errors"
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

			return nil
		}).
		RunE(func(cmd *cobra.Command, args []string) error {

			files, err := archiver.FilesFromDisk(nil, lo.Associate(paths, func(item string) (string, string) {
				return item, item
			}))
			if err != nil {
				return err
			}

			format := archiver.CompressedArchive{
				Compression: archiver.Gz{},
				Archival:    archiver.Tar{},
			}

			var tarball []byte
			var tarballIo = bytes.NewBuffer(tarball)
			if err = format.Archive(context.TODO(), tarballIo, files); err != nil {
				return err
			}

			encoded := base64.StdEncoding.EncodeToString(tarballIo.Bytes())

			slog.Info("Uploading...")
			slog.Debug("Uploading...", "size", len(encoded))

			client := gist.GetClient()
			filename := env.Config().GistFileName
			_, _, err = client.Gists.Create(context.TODO(), &github.Gist{
				Description: github.String("Gistrge: " + description),
				Public:      github.Bool(false),
				Files: map[github.GistFilename]github.GistFile{
					github.GistFilename(filename): {
						Filename: github.String(filename),
						Content:  github.String(encoded),
					},
				},
			})
			if err != nil {
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
