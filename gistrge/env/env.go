package env

import (
	"os"
)

// Get GitHub Token from environment variable
var GitHubToken string = os.Getenv("GISTRGE_GITHUB_TOKEN")

var DescriptionRegExpStr string = os.Getenv("GISTRGE_GIST_DESCRIPTION_REGEXP")

var GistFileName string = os.Getenv("GISTRGE_GIST_FILENAME")

func init() {
	if DescriptionRegExpStr == "" {
		DescriptionRegExpStr = `^Gistrge: `
	}

	if GistFileName == "" {
		GistFileName = "gistrge.txt"
	}
}
