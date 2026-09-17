//go:build (darwin || linux) && !android

package main

import (
	"errors"
	"os"
)

func refuseElevatedStartup() error {
	if elevatedIDs(os.Getuid(), os.Geteuid()) {
		return errors.New("refusing to run ReClashCore with elevated privileges")
	}
	return nil
}
