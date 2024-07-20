package gist

import (
	"context"

	"github.com/cockroachdb/errors"
	"github.com/google/go-github/v63/github"
)

func GetAll(userID string) ([]*github.Gist, error) {
	client := GetClient()

	if userID == "" {
		user, err := GetMe()
		if err != nil {
			return nil, errors.Wrap(err, "failed to get user")
		}
		userID = user.GetLogin()
	}

	list, _, err := client.Gists.List(context.Background(), userID, nil)
	if err != nil {
		return nil, errors.Wrap(err, "failed to list gists")
	}

	return list, nil

}
