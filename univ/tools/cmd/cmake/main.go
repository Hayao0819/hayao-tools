package cmake

import (
	"fmt"

	"github.com/Hayao0819/Hayao-Tools/univ/tools/utils"
)

func Run() error {
	// get src dir
	src, err := utils.GetSrcDir()
	if err != nil {
		return err
	}

	// get c files
	cfiles, err := getCFiles(src)
	if err != nil {
		return err
	}

	// ask name
	name, err := askName()
	if err != nil {
		return err
	}

	fmt.Println("name:", name)
	fmt.Println("src:", src)
	fmt.Println("cfiles:", cfiles)

	return nil
}
