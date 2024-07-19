package gist

import "github.com/google/go-github/v63/github"

func New(desc string, public bool) *github.Gist {
	g := github.Gist{
		Description: github.String(desc),
		Public:      github.Bool(public),
	}
	return &g
}

func AddFile(gist *github.Gist, filename, content string) {

	if gist.Files == nil {
		gist.Files = make(map[github.GistFilename]github.GistFile)
	}

	gist.Files[github.GistFilename(filename)] = github.GistFile{
		Filename: github.String(filename),
		Content:  github.String(content),
	}
}
