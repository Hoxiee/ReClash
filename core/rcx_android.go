//go:build android

package core

import (
	"encoding/json"

	"core/rcx"
)

func SetRcxHints(data string) {
	defer recoverExport("SetRcxHints")
	var hints rcx.Hints
	if json.Unmarshal([]byte(data), &hints) != nil {
		return
	}
	if rcxDefer(hints) {
		return
	}
	if e := rcxReady(); e != nil {
		e.SetHints(hints)
	}
}

func rcxWatchPower() {}
