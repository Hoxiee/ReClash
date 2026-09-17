//go:build android && cgo

package main

//#include "bride.h"
import "C"
import "unsafe"

func protectSubscription(callback unsafe.Pointer, fd int) bool {
	return C.protect_subscription(callback, C.int(fd)) != 0
}

func protect(callback unsafe.Pointer, fd int) bool {
	return C.protect(callback, C.int(fd)) != 0
}

func resolveUid(callback unsafe.Pointer, protocol int, source, target string) int {
	s := C.CString(source)
	defer C.free(unsafe.Pointer(s))
	t := C.CString(target)
	defer C.free(unsafe.Pointer(t))
	return int(C.resolve_uid(callback, C.int(protocol), s, t))
}

func resolvePackage(callback unsafe.Pointer, uid int) string {
	return takeCString(C.resolve_package(callback, C.int(uid)))
}

func runDoctorProbe(callback unsafe.Pointer, request string) string {
	value := C.CString(request)
	defer C.free(unsafe.Pointer(value))
	return takeCString(C.doctor_probe(callback, value))
}

func cancelDoctorProbe(callback unsafe.Pointer, probeID string) {
	value := C.CString(probeID)
	defer C.free(unsafe.Pointer(value))
	C.cancel_doctor_probe(callback, value)
}

func invokeResult(callback unsafe.Pointer, data string) {
	s := C.CString(data)
	defer C.free(unsafe.Pointer(s))
	C.result(callback, s)
}

func releaseObject(callback unsafe.Pointer) {
	C.release_object(callback)
}

func takeCString(s *C.char) string {
	defer C.free_string(s)
	return C.GoString(s)
}
