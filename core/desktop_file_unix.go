//go:build linux || darwin

package core

import (
	"os"
	"syscall"
)

func singleLinkedCoreFile(_ *os.File, info os.FileInfo) bool {
	stat, ok := info.Sys().(*syscall.Stat_t)
	return ok && stat.Nlink == 1
}
