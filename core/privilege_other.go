//go:build !(darwin || linux) || android

package main

func refuseElevatedStartup() error {
	return nil
}
