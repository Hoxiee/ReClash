package main

// subscriptionNodeLabel is the config-derived identity Flutter resolves and
// hands the core, keyed by outbound name. The core never parses config
// semantics itself, so protocol/group/position all arrive from Dart.
type subscriptionNodeLabel struct {
	Protocol     string   `json:"protocol"`
	Transport    string   `json:"transport"`
	Groups       []string `json:"groups"`
	PositionHint int      `json:"positionHint"`
}

type subscriptionNodeMetadata struct {
	nodes   map[string]subscriptionNodeLabel
	presets []string
}

type subscriptionMetadataParams struct {
	Nodes   map[string]subscriptionNodeLabel `json:"nodes"`
	Presets []string                         `json:"presets"`
}

type subscriptionOutcomeReport struct {
	Key      string `json:"key"`
	Attempts int    `json:"attempts"`
	Failure  int    `json:"failure"`
}

type subscriptionGroupReport struct {
	Group    string `json:"group"`
	Attempts int    `json:"attempts"`
	Failure  int    `json:"failure"`
}

type subscriptionClassReport struct {
	Class string `json:"class"`
	Count int    `json:"count"`
}

type subscriptionNodeReport struct {
	Alias         string   `json:"alias"`
	Protocol      string   `json:"protocol,omitempty"`
	Transport     string   `json:"transport,omitempty"`
	EgressCountry string   `json:"egressCountry,omitempty"`
	Groups        []string `json:"groups,omitempty"`
	PositionHint  int      `json:"positionHint,omitempty"`
	Attempts      int      `json:"attempts"`
	Failures      int      `json:"failures"`
	Successes     int      `json:"successes"`
	FailStreak    int      `json:"failStreak"`
	DominantClass string   `json:"dominantClass,omitempty"`
	DelayBucketMs int64    `json:"delayBucketMs,omitempty"`
}

type subscriptionDialReport struct {
	Attempts     int                         `json:"attempts"`
	Success      int                         `json:"success"`
	Failure      int                         `json:"failure"`
	ByTransport  []subscriptionOutcomeReport `json:"byTransport"`
	ByStage      []subscriptionOutcomeReport `json:"byStage"`
	ByErrorClass []subscriptionClassReport   `json:"byErrorClass"`
	ByProtocol   []subscriptionOutcomeReport `json:"byProtocol"`
	ByGroup      []subscriptionGroupReport   `json:"byGroup"`
	ByEgress     []subscriptionOutcomeReport `json:"byEgress"`
}

type subscriptionReport struct {
	SchemaVersion     int                    `json:"schemaVersion"`
	GeneratedAt       int64                  `json:"generatedAt"`
	CoreVersion       string                 `json:"coreVersion"`
	Platform          string                 `json:"platform"`
	Architecture      string                 `json:"architecture"`
	WindowStart       int64                  `json:"windowStart"`
	WindowEnd         int64                  `json:"windowEnd"`
	Terrain           string                 `json:"terrain,omitempty"`
	Env               string                 `json:"env,omitempty"`
	Presets           []string               `json:"presets,omitempty"`
	DroppedEvents     int                    `json:"droppedEvents,omitempty"`
	ConfigNodeCount   int                    `json:"configNodeCount"`
	ObservedNodeCount int                    `json:"observedNodeCount"`
	RuntimeDial       subscriptionDialReport `json:"runtimeDial"`
	// Nodes lists only the worst top-N observed nodes that had failures, not the
	// whole park; ConfigNodeCount and ObservedNodeCount are its denominators.
	Nodes []subscriptionNodeReport `json:"nodes"`
}
