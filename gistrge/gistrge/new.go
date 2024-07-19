package gistrge

import (
	"bytes"
	"context"
	"encoding/base64"

	"github.com/Hayao0819/Hayao-Tools/gistrge/env"
	"github.com/Hayao0819/Hayao-Tools/gistrge/gist"
	"github.com/google/go-github/v63/github"
	"github.com/mholt/archiver/v4"
	"github.com/samber/lo"
)

func New(gist *github.Gist) (*Gistrge, error) {
	g := Gistrge{
		Gist:        gist,
		Description: "",
	}
	desc, err := g.GetDescription()
	if err != nil {
		return nil, err
	}
	g.Description = desc
	return &g, nil
}

func FromFiles(desc string, path ...string) (*Gistrge, error) {
	files, err := archiver.FilesFromDisk(nil, lo.Associate(path, func(item string) (string, string) {
		return item, item
	}))
	if err != nil {
		return nil, err
	}

	format := archiver.CompressedArchive{
		Compression: archiver.Gz{},
		Archival:    archiver.Tar{},
	}

	var tarball []byte
	var tarballIo = bytes.NewBuffer(tarball)
	if err = format.Archive(context.TODO(), tarballIo, files); err != nil {
		return nil, err
	}

	encoded := base64.StdEncoding.EncodeToString(tarballIo.Bytes())

	newgist := gist.New(desc, false)
	gist.AddFile(newgist, env.Config().GistFileName, encoded)

	return New(newgist)
}
