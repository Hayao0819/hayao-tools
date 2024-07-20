package gist

import (
	"github.com/google/go-github/v63/github"
)

func GetFileURL(gist *github.Gist, filename string) (string, error) {
	targetFile := gist.Files[github.GistFilename(filename)]
	return targetFile.GetRawURL(), nil
}
