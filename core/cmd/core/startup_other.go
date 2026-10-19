//go:build !android && !linux && !darwin && !windows

package main

import "errors"

func prepareDesktopStartup(args []string) (string, func(), error) {
	if len(args) != 1 || args[0] == "" {
		return "", nil, errors.New("invalid desktop Core arguments")
	}
	return args[0], func() {}, nil
}
