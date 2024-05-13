package cmake

import "github.com/manifoldco/promptui"

func askName() (string, error) {
	ui := promptui.Prompt{
		Label: "Enter project name",
	}

	name, err := ui.Run()
	if err != nil {
		return "", err
	}

	return name, nil
}
