package main

import (
	"os"

	"github.com/Hayao0819/zash/go/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		// fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
