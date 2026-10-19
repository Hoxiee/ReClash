//go:build !linux && !darwin && !windows

package core

import "os"

func singleLinkedCoreFile(_ *os.File, _ os.FileInfo) bool {
	return false
}
