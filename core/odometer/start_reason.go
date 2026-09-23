package odometer

import "sync"

// A prepareUp FFI signal sets the start reason; the next NoteUp consumes it once.
var odoStartIntent struct {
	sync.Mutex
	reason string
}

func setOdoStartReason(reason string) {
	odoStartIntent.Lock()
	odoStartIntent.reason = reason
	odoStartIntent.Unlock()
}

func takeOdoStartReason() string {
	odoStartIntent.Lock()
	defer odoStartIntent.Unlock()
	reason := odoStartIntent.reason
	odoStartIntent.reason = ""
	return reason
}
