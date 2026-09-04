package main

import (
	"strings"
	"time"

	"github.com/metacubex/mihomo/adapter"
)

var rcxEngineInstance = newRcxEngine(rcxCoreRuntime{})

// RCX-NODE stays selectable by hand, which is what arms manual-hold.
func rcxIsServiceGroup(name string) bool {
	return strings.HasPrefix(name, rcxGroupPrefix) && name != rcxGroupNode
}

func init() {
	registerMethod(rcxConfigureMethod, withArguments(func(config *rcxConfig, response MethodResponse) {
		rcxEngineInstance.Configure(*config)
		response.success(true)
	}))
	registerMethod(rcxNetworkMethod, withArguments(func(payload *rcxNetworkPayload, response MethodResponse) {
		rcxEngineInstance.Network(*payload)
		response.success(true)
	}))
	registerMethod(rcxSetEnabledMethod, withArguments(func(enabled *bool, response MethodResponse) {
		rcxEngineInstance.SetEnabled(*enabled)
		response.success(true)
	}))
	registerMethod(rcxStatusMethod, withoutArguments(func(response MethodResponse) {
		response.success(rcxEngineInstance.Status())
	}))
	registerMethod(rcxReportMethod, withoutArguments(func(response MethodResponse) {
		response.success(rcxEngineInstance.Report())
	}))
	registerMethod(rcxDeepScanMethod, withoutArguments(func(response MethodResponse) {
		rcxEngineInstance.DeepScan()
		response.success(true)
	}))

	adapter.DialResultHook = func(name, source string, err error, elapsed time.Duration) {
		rcxEngineInstance.NoteDial(name, source, err != nil, elapsed, time.Now())
	}
}
