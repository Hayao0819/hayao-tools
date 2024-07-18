package gistrge

import (
	"io"
	"net/http"

	"github.com/Hayao0819/Hayao-Tools/gistrge/env"
	"github.com/Hayao0819/Hayao-Tools/gistrge/gist"
	"github.com/google/go-github/v63/github"
	"github.com/samber/lo"
)

func GetGistrges(userId string) ([]*Gistrge, error) {
	gists, err := gist.GetAll(userId)
	if err != nil {
		return nil, err
	}

	filtered := lo.FilterMap(gists, func(item *github.Gist, index int) (*Gistrge, bool) {
		gistre, err := NewGistrge(item)
		if err != nil {
			return nil, false
		}

		isCorrect, err := gistre.IsCorrect()
		if err != nil {
			return nil, false
		}
		return gistre, isCorrect
	})

	return filtered, nil
}

func GetFileURL(g *Gistrge) string {
	return gist.GetFileURL(g.Gist, env.Config().GistFileName)
}

func GetContent(g *Gistrge) (string, error) {
	url := GetFileURL(g)
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
