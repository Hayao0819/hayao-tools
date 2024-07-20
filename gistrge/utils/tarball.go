package utils

import (
	"bytes"
	"context"
	"fmt"
	"io"

	"github.com/mholt/archiver/v4"
)

func ArchiverIdentifyBytes(data []byte) (archiver.Format, io.Reader, error) {
	reader := bytes.NewReader(data)
	return archiver.Identify("", reader)
}

func ExtractBytes(data []byte) (any, error) {
	format, reader, err := ArchiverIdentifyBytes(data)
	if err != nil {
		return nil, err
	}

	// Extract
	//fmt.Printf("%+v\n", format)
	if ex, ok := format.(archiver.CompressedArchive); ok {
		ex.Extract(context.TODO(), reader, nil, func(ctx context.Context, f archiver.File) error {
			fmt.Println(f.Name())
			return nil
		})
	}

	return nil, nil
}
