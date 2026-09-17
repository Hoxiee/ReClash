//go:build !linux || android

package main

func restrictChildPrivileges() error {
	return nil
}
