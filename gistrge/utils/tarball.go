package utils

import (
	"bytes"
	"context"
	"io"
	"log/slog"
	"os"
	"path/filepath"

	"github.com/cockroachdb/errors"
	"github.com/mholt/archiver/v4"
)

func ArchiverIdentifyBytes(data []byte) (archiver.Format, io.Reader, error) {
	reader := bytes.NewReader(data)
	return archiver.Identify("", reader)
}

func ExtractBytes(data []byte, dest string) (any, error) {
	format, reader, err := ArchiverIdentifyBytes(data)
	if err != nil {
		return nil, err
	}

	// Extract
	//fmt.Printf("%+v\n", format)
	errs := []error{}
	if ex, ok := format.(archiver.CompressedArchive); ok {
		err := ex.Extract(context.Background(), reader, nil, func(ctx context.Context, f archiver.File) error {
			slog.Debug("Extracting\n", "file", f.NameInArchive, "dest", dest)

			if f.IsDir() {
				return nil
			}

			if err := os.MkdirAll(filepath.Join(dest, filepath.Dir(f.NameInArchive)), 0755); err != nil {
				errs = append(errs, err)
			}

			vfile, err := f.Open()
			if err != nil {
				errs = append(errs, err)
				return nil
			}
			defer vfile.Close()

			filebytes, err := io.ReadAll(vfile)
			if err != nil {
				errs = append(errs, err)
			}

			destFile, err := os.Create(filepath.Join(dest, f.NameInArchive))
			if err != nil {
				errs = append(errs, err)
			}
			defer destFile.Close()

			if err := destFile.Chmod(f.Mode()); err != nil {
				errs = append(errs, err)
			}

			if _, err := destFile.Write(filebytes); err != nil {
				errs = append(errs, err)
			}

			return nil
		})

		if err != nil {
			errs = append(errs, err)
		}
	}
	if len(errs) > 0 {
		return nil, errors.Join(errs...)
	}

	return nil, nil
}
