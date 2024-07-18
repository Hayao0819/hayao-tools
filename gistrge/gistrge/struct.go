package gistrge

import (
	"strings"

	"github.com/Hayao0819/Hayao-Tools/gistrge/env"
	"github.com/google/go-github/v63/github"
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

func NewGistrge(gist *github.Gist) (*Gistrge, error) {
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
