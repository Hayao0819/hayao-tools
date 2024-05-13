package utils

import (
	"os"
	"path"

	"github.com/Hayao0819/nahi/flist"
	"github.com/manifoldco/promptui"
)

func GetSrcDir() (string, error) {
	pwd, err := os.Getwd()
	if err != nil {
		return "", err
	}

	return path.Join(pwd, "src"), nil
}

func SelectFile(list *[]string) (*string, error) {
	ui := promptui.Select{
		Label: "Select file to build",
		Items: *list,
	}

	_, result, err := ui.Run()
	if err != nil {
		return nil, err
	}

	return &result, nil

}

func GetSourceFiles(src string) (*[]string, error) {
	list, err := flist.Get(src, flist.WithFileOnly())
	if err != nil {
		return nil, err
	}

	return list, nil
}

func AskOutPath() (string, error) {
	ui := promptui.Prompt{
		Label:   "Enter output name",
		Default: "a.out",
	}

	outPath, err := ui.Run()
	if err != nil {
		return "", err
	}

	return outPath, nil
}
