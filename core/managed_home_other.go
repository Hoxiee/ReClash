//go:build !windows

package main

func permittedCoreHome(_ string) bool { return true }
