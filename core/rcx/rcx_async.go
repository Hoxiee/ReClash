package rcx

import (
	"runtime"

	"github.com/metacubex/mihomo/log"
)

func safeGoDetached(name string, run func()) {
	go func() {
		defer func() {
			if r := recover(); r != nil {
				buf := make([]byte, 4096)
				log.Errorln("panic in %s: %v\n%s", name, r, buf[:runtime.Stack(buf, false)])
			}
		}()
		run()
	}()
}
