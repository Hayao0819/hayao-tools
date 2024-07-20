package gistrge

import (
	"context"
	"encoding/base64"
	"io"
	"net/http"
	"strings"

	"github.com/Hayao0819/Hayao-Tools/gistrge/env"
	"github.com/Hayao0819/Hayao-Tools/gistrge/gist"
	"github.com/google/go-github/v63/github"
	"github.com/cockroachdb/errors"
)

type Gistrge struct {
	gist        *github.Gist
	Description string
	uploadData  *UploadData
	//content     string
}

type UploadData struct {
	Data string `json:"data"`
}

func (g *Gistrge) IsCorrect() (bool, error) {
	reg, err := env.UseDescriptionRegExp()
	if err != nil {
		return false, err
	}

	desc := g.gist.GetDescription()

	if len(strings.TrimSpace(desc)) < 1 {
		return false, nil
	}
	return reg.MatchString(desc), nil
}

func (g *Gistrge) GetDescriptionFromGist() (string, error) {
	reg, err := env.UseDescriptionRegExp()
	if err != nil {
		return "", err
	}

	return reg.ReplaceAllString(g.gist.GetDescription(), ""), nil
}

func (g *Gistrge) CreateNewGist() error {
	client := gist.GetClient()
	_, _, err := client.Gists.Create(context.Background(), g.gist)
	if err != nil {
		return errors.Wrap(err, "failed to create gist")
	}
	return nil
}

func (g *Gistrge) GetFileURLFromGist() (string, error) {

	if g.gist.ID == nil {
		return "", errors.New("gist id is nil")
	}

	return gist.GetFileURL(g.gist, env.Config().GistFileName)
}

func (g *Gistrge) FetchContentFromGist() (string, error) {
	url, err := g.GetFileURLFromGist()
	if err != nil {
		return "", err
	}
	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}

func (g *Gistrge) GetUploadData() (*UploadData, error) {
	if g.uploadData == nil {
		return nil, errors.New("upload data is nil")
	}
	return g.uploadData, nil
}

func (g *Gistrge) DecodeFile() ([]byte, error) {

	uploadData, err := g.GetUploadData()
	if err != nil {
		return nil, err
	}

	decoded, err := base64.StdEncoding.DecodeString(uploadData.Data)
	if err != nil {
		return nil, err
	}
	return decoded, nil
}

// func (g *Gistrge) Extract() (map[string][]byte, error) {
// 	decoded, err := g.Decode()
// 	if err != nil {
// 		return nil, err
// 	}

// }
