package gist

import (
	"context"

	"github.com/google/go-github/v63/github"
)

func GetMe() (*github.User, error) {
	client := GetClient()
	user, _, err := client.Users.Get(context.Background(), "")
	return user, err
}
