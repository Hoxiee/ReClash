package main

import (
	"strings"
	"time"

	"github.com/metacubex/mihomo/adapter"
)

var rcxEngineInstance = newRcxEngine(rcxCoreRuntime{})

// Every RCX group is engine-owned: the host's persisted selection map must
// never ForceSet one, or a stale manual pick clobbers the engine's node on
// every config re-apply. A user's RCX-NODE pick is not a ForceSet: it arrives
// through handleChangeProxy, which sets and pins in one path.
func rcxIsServiceGroup(name string) bool {
	return strings.HasPrefix(name, rcxGroupPrefix)
}

func init() {
	registerMethod(rcxConfigureMethod, withArguments(func(config *rcxConfig, response MethodResponse) {
		rcxEngineInstance.Configure(*config)
		response.success(true)
	}))
	registerMethod(rcxNetworkMethod, withArguments(func(payload *networkFactsPayload, response MethodResponse) {
		coreNetworkFacts.Update(*payload)
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

	adapter.DialResultHook = func(name, _ string, err error, elapsed time.Duration) {
		rcxEngineInstance.NoteDial(name, err != nil, elapsed, time.Now())
	}
}
