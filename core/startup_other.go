//go:build !windows && !(android && cgo)

package main

import "errors"

func prepareDesktopStartup(args []string) (string, func(), error) {
	if len(args) < 2 {
		return "", nil, errors.New("arguments error")
	}
	return args[1], func() {}, nil
}
