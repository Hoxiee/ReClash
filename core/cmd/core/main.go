//go:build !android

package main

import (
	"core"
	"fmt"
	"os"
)

func main() {
	address, cleanup, err := prepareDesktopStartup(os.Args[1:])
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer cleanup()
	go core.ExitOnTermination()
	core.StartServer(address)
}
