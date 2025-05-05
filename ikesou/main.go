package main

import (
	"os"

	cmd "github.com/Hayao0819/Hayao-Tools/ikesou/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		os.Exit(1)
	}
}
