package gistrge

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"

	"github.com/Hayao0819/Hayao-Tools/gistrge/env"
	"github.com/Hayao0819/Hayao-Tools/gistrge/gist"
	"github.com/google/go-github/v63/github"
	"github.com/mholt/archiver/v4"
	"github.com/samber/lo"
)

func NewUploadData(path ...string) (*UploadData, error) {
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

	// Create tarball
	var tarball []byte
	var tarballIo = bytes.NewBuffer(tarball)
	if err = format.Archive(context.TODO(), tarballIo, files); err != nil {
		return nil, err
	}

	// Create UploadData
	data := UploadData{
		Data: base64.StdEncoding.EncodeToString(tarballIo.Bytes()),
	}

	return &data, nil
}

func UnmarshalUploadData(data string) (*UploadData, error) {
	uploadData := UploadData{}
	err := json.Unmarshal([]byte(data), &uploadData)
	if err != nil {
		return nil, err
	}
	return &uploadData, nil

}

func FromFetchedGist(gist *github.Gist) (*Gistrge, error) {
	g := Gistrge{
		gist:        gist,
		Description: "",
	}

	// Set description
	desc, err := g.GetDescriptionFromGist()
	if err != nil {
		return nil, err
	}
	g.Description = desc

	// Set upload data
	content, err := g.FetchContentFromGist() // uploadData is still nil
	
	if err != nil {
		return nil, err
	}
	uploadData, err := UnmarshalUploadData(content)
	if err != nil {
		return nil, err
	}
	g.uploadData = uploadData

	return &g, nil
}

func FromFiles(desc string, path ...string) (*Gistrge, error) {

	// Create UploadData
	uploadData, err := NewUploadData(path...)
	if err != nil {
		return nil, err
	}

	// UploadData to JSON
	uploadDataJson, err := json.Marshal(uploadData)
	if err != nil {
		return nil, err
	}

	// Create new gist
	newgist := gist.New(desc, false)
	gist.AddFile(newgist, env.Config().GistFileName, string(uploadDataJson))

	new := Gistrge{
		gist:        newgist,
		Description: desc,
		uploadData:  uploadData,
	}

	return &new, nil
}
