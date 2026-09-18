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
