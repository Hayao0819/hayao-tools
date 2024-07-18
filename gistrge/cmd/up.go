package cmd

import (
	"bytes"
	"context"
	"encoding/base64"
	"log/slog"

	"github.com/Hayao0819/Hayao-Tools/gistrge/mobra"
	"github.com/Hayao0819/nahi/futils"
	"github.com/mholt/archiver/v4"
	"github.com/samber/lo"
	"github.com/spf13/cobra"
)

func UpCmd() *cobra.Command {

	paths := []string{}
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

			// TODO: Implement upload process

			return nil
		}).
		Cobra()

	return cmd
}

func init() {
	Registory.Add(UpCmd())
}
