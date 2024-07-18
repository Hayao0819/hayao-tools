package gist

import (
	"github.com/Hayao0819/Hayao-Tools/gistrge/env"
	"github.com/google/go-github/v63/github"
)

func GetClient() *github.Client {
	return github.NewClient(nil).WithAuthToken(env.Config().GitHubToken)
}
