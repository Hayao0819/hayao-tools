package main

import (
	"fmt"
	"os"

	"github.com/Hayao0819/Hayao-Tools/gistrge/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		fmt.Printf("%+v\n", err)
		os.Exit(-1)
	}
}
