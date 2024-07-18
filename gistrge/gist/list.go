package gist

import (
	"context"

	"github.com/google/go-github/v63/github"
)

func GetAll(userID string) ([]*github.Gist, error) {
	client := GetClient()

	if userID == "" {
		user, err := GetMe()
		if err != nil {
			return nil, err
		}
		userID = user.GetLogin()
	}

	list, _, err := client.Gists.List(context.TODO(), userID, nil)
	if err != nil {
		return nil, err
	}

	return list, nil

}
