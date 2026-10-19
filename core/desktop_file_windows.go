//go:build windows

package core

import (
	"os"
	"syscall"
)

func singleLinkedCoreFile(file *os.File, _ os.FileInfo) bool {
	var information syscall.ByHandleFileInformation
	return syscall.GetFileInformationByHandle(syscall.Handle(file.Fd()), &information) == nil && information.NumberOfLinks == 1
}
