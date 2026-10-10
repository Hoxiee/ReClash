package main

import (
	"sync"
	"time"
)

var subscriptionReporterInstance = newSubscriptionReporter()

var subscriptionMetadataState struct {
	mu       sync.Mutex
	metadata subscriptionNodeMetadata
}

func init() {
	registerMethod(subscriptionReportMetadataMethod, withArguments(func(params *subscriptionMetadataParams, response MethodResponse) {
		setSubscriptionMetadata(*params)
		response.success(true)
	}))
	registerMethod(subscriptionReportExportMethod, withoutArguments(func(response MethodResponse) {
		response.success(exportSubscriptionReport())
	}))
	registerMethod(subscriptionReportExportVerboseMethod, withoutArguments(func(response MethodResponse) {
		response.success(exportVerboseSubscriptionReport())
	}))
}

func setSubscriptionMetadata(params subscriptionMetadataParams) {
	nodes := make(map[string]subscriptionNodeLabel, len(params.Nodes))
	for name, label := range params.Nodes {
		nodes[name] = label
	}
	subscriptionMetadataState.mu.Lock()
	subscriptionMetadataState.metadata = subscriptionNodeMetadata{nodes: nodes, presets: params.Presets}
	subscriptionMetadataState.mu.Unlock()
}

func currentSubscriptionMetadata() subscriptionNodeMetadata {
	subscriptionMetadataState.mu.Lock()
	defer subscriptionMetadataState.mu.Unlock()
	return subscriptionMetadataState.metadata
}

func exportSubscriptionReport() subscriptionReport {
	counters := subscriptionReporterInstance.Snapshot()
	metadata := currentSubscriptionMetadata()
	status := rcxEngineInstance.Status()
	return buildSubscriptionReport(
		counters,
		metadata,
		time.Now(),
		status.Terrain,
		status.Env,
		rcxEngineInstance.ExitCountryFor,
	)
}

// exportVerboseSubscriptionReport adds the full-park per-node section the opt-in
// telemetry send carries. It is a superset of the default export, so the public
// report link keeps using the lean one.
func exportVerboseSubscriptionReport() subscriptionReport {
	counters := subscriptionReporterInstance.Snapshot()
	metadata := currentSubscriptionMetadata()
	status := rcxEngineInstance.Status()
	report := buildSubscriptionReport(
		counters,
		metadata,
		time.Now(),
		status.Terrain,
		status.Env,
		rcxEngineInstance.ExitCountryFor,
	)
	report.Park = buildParkNodes(counters, metadata, rcxEngineInstance.ExitCountryFor)
	return report
}
