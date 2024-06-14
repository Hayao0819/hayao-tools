package main

import (
	"os"

	"github.com/Hayao0819/Hayao-Tools/univ/tools/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		os.Exit(1)
	}
}
