package gistrge

import (
	"github.com/Hayao0819/Hayao-Tools/gistrge/gist"
	"github.com/google/go-github/v63/github"
	"github.com/samber/lo"
)

func GetGistrges(userId string) (GistrgeList, error) {
	gists, err := gist.GetAll(userId)
	if err != nil {
		return nil, err
	}

	filtered := lo.FilterMap(gists, func(item *github.Gist, index int) (*Gistrge, bool) {
		gistre, err := New(item)
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
