package gist

import "github.com/google/go-github/v63/github"

func GetFileURL(gist *github.Gist, filename string) string {
	return *gist.Files[github.GistFilename(filename)].RawURL
}
