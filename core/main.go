//go:build !(android && cgo)

package main

import (
	"fmt"
	"os"
)

func main() {
	args := os.Args
	if len(args) <= 1 {
		fmt.Fprintln(os.Stderr, "Arguments error")
		os.Exit(1)
	}
	if err := refuseElevatedStartup(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if err := restrictChildPrivileges(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	go exitOnTermination()
	startServer(args[1])
}
