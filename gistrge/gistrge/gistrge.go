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
	"github.com/pkg/errors"
)

type Gistrge struct {
	Gist        *github.Gist
	Description string
}

func (g *Gistrge) IsCorrect() (bool, error) {
	reg, err := env.UseDescriptionRegExp()
	if err != nil {
		return false, err
	}

	desc := g.Gist.GetDescription()

	if len(strings.TrimSpace(desc)) < 1 {
		return false, nil
	}
	return reg.MatchString(desc), nil
}

func (g *Gistrge) GetDescription() (string, error) {
	reg, err := env.UseDescriptionRegExp()
	if err != nil {
		return "", err
	}

	return reg.ReplaceAllString(g.Gist.GetDescription(), ""), nil
}

func (g *Gistrge) Create() error {
	client := gist.GetClient()
	_, _, err := client.Gists.Create(context.TODO(), g.Gist)
	if err != nil {
		return errors.Wrap(err, "failed to create gist")
	}
	return nil
}

func (g *Gistrge) GetFileURL() string {
	return gist.GetFileURL(g.Gist, env.Config().GistFileName)
}

func (g *Gistrge) GetContent() (string, error) {
	url := g.GetFileURL()
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

func (g *Gistrge) Decode() ([]byte, error) {
	content, err := g.GetContent()
	if err != nil {
		return nil, errors.Wrap(err, "failed to get content")
	}

	decoded, err := base64.StdEncoding.DecodeString(content)
	if err != nil {
		return nil, errors.Wrap(err, "failed to decode base64")
	}
	return decoded, nil
}

// func (g *Gistrge) Extract() (map[string][]byte, error) {
// 	decoded, err := g.Decode()
// 	if err != nil {
// 		return nil, err
// 	}

// }
