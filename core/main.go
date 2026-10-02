//go:build !(android && cgo)

package main

import (
	"fmt"
	"os"
)

func main() {
	address, cleanup, err := prepareDesktopStartup(os.Args)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer cleanup()
	if err := refuseElevatedStartup(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if err := restrictChildPrivileges(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	go exitOnTermination()
	startServer(address)
}
