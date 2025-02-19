package main

import (
	"fmt"
	"os"
)

func main() {
	r := rootCmd()
	if err := r.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
