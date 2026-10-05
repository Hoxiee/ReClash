package rcx

import (
	"reflect"
	"time"
)

// Comparable on purpose: publish diffs it to keep the host from redrawing on
// every tick, so it carries only the summary the hero row needs.
type rcxLaneStatus struct {
	ID         string `json:"id"`
	Group      string `json:"group"`
	State      string `json:"state"`
	Node       string `json:"node"`
	Candidates int    `json:"candidates"`
	Eligible   int    `json:"eligible"`
	Searching  bool   `json:"searching"`
	Fallback   string `json:"fallback"`
	Reason     string `json:"reason"`
	SwitchedAt int64  `json:"switchedAt"`
}

type rcxStatus struct {
	Enabled    bool            `json:"enabled"`
	Preset     string          `json:"preset"`
	Strategy   string          `json:"strategy"`
	Mode       string          `json:"mode"`
	Terrain    string          `json:"terrain"`
	Env        string          `json:"env"`
	Node       string          `json:"node"`
	DelayMs    int             `json:"delay"`
	Reason     string          `json:"reason"`
	Searching  bool            `json:"searching"`
	Deep       bool            `json:"deep"`
	Pinned     bool            `json:"pinned"`
	PinNode    string          `json:"pinNode"`
	Direct     string          `json:"direct"`
	Candidates int             `json:"candidates"`
	Eligible   int             `json:"eligible"`
	SwitchedAt int64           `json:"switchedAt"`
	Lanes      []rcxLaneStatus `json:"lanes,omitempty"`
	// Canary outcomes ride the pushed status too: the hero line tells a
	// DPI-filtered network (foreign up, censored SNI cut) from a truly
	// limited one (foreign down) without opening the full report.
	Link rcxLinkReport `json:"link"`
}

type rcxCandidateReport struct {
	Node       string `json:"node"`
	Country    string `json:"country"`
	Exit       string `json:"exit"`
	Origin     string `json:"origin"`
	Verdict    string `json:"verdict"`
	Evidence   string `json:"evidence"`
	Block      string `json:"block"`
	MedianMs   int    `json:"medianMs"`
	HostMs     int    `json:"hostDelay"`
	Band       int    `json:"band"`
	LatencyMs  int    `json:"latencyMs"`
	RankMs     int    `json:"rankMs"`
	Unproven   bool   `json:"unproven"`
	Order      int    `json:"order"`
	Prefer     bool   `json:"prefer"`
	RuleCapped bool   `json:"ruleCapped"`
	Degraded   bool   `json:"degraded"`
	HomeRisk   int    `json:"homeRisk"`
	Recurrence int    `json:"recurrence"`
	Confirmed  bool   `json:"confirmed"`
	Breaker    bool   `json:"breaker"`
	UDP        bool   `json:"udp"`
	Fails      int    `json:"fails"`
	CoolFor    int    `json:"coolFor"`
	Current    bool   `json:"current"`
	Trust      string `json:"trust"`
	Confidence string `json:"confidence"`
}

type rcxSwitchReport struct {
	From   string `json:"from"`
	To     string `json:"to"`
	Reason string `json:"reason"`
	At     int64  `json:"at"`
}

type rcxCanaryReport struct {
	Addr     string `json:"addr"`
	Domestic bool   `json:"domestic"`
	Outcome  string `json:"outcome"`
	DelayMs  int    `json:"delay"`
}

type rcxLinkReport struct {
	Transport string `json:"transport"`
	Validated bool   `json:"validated"`
	Portal    bool   `json:"portal"`
	Metered   bool   `json:"metered"`
	Foreign   string `json:"foreign"`
	Domestic  string `json:"domestic"`
	SNI       string `json:"sni"`
	Since     int64  `json:"since"`
}

type rcxMetricsReport struct {
	EnabledMillis     int64    `json:"enabledMillis"`
	AvailableMillis   int64    `json:"availableMillis"`
	Availability      int      `json:"availability"`
	Incidents         int      `json:"incidents"`
	StandbyHits       int      `json:"standbyHits"`
	ProviderIncidents int      `json:"providerIncidents"`
	MarkerIncidents   int      `json:"markerIncidents"`
	LastFailover      int64    `json:"lastFailover"`
	AverageFailover   int64    `json:"averageFailover"`
	LastOutage        int64    `json:"lastOutage"`
	AverageOutage     int64    `json:"averageOutage"`
	ActiveCircuits    []string `json:"activeCircuits"`
	ActiveMarkers     []string `json:"activeMarkers"`
}

// The overview's whole payload, pulled on demand rather than pushed: it is large,
// it changes on every tick, and nobody reads it while the page is closed.
type rcxReport struct {
	Status     rcxStatus            `json:"status"`
	Link       rcxLinkReport        `json:"link"`
	Canaries   []rcxCanaryReport    `json:"canaries"`
	Candidates []rcxCandidateReport `json:"candidates"`
	History    []rcxSwitchReport    `json:"history"`
	Metrics    rcxMetricsReport     `json:"metrics"`
	Bands      []int                `json:"bands"`
	Ladder     []rcxRungSpec        `json:"ladder"`
	ProbesLeft int                  `json:"probesLeft"`
	ProbeCap   int                  `json:"probeCap"`
	Manual     bool                 `json:"manual"`
	Discovery  rcxDiscoveryReport   `json:"discovery"`
	At         int64                `json:"at"`
}

func rcxOutcomeName(outcome rcxProbeOutcome) string {
	switch outcome {
	case rcxProbeOK:
		return "ok"
	case rcxProbeStatusMismatch:
		return "mismatch"
	case rcxProbeFail:
		return "fail"
	default:
		return "unknown"
	}
}

func (e *rcxEngine) publish(reason rcxReason, ranked []rcxRanked, input rcxDecisionInput) {
	now := e.runtime.Now()
	eligible := 0
	for _, row := range ranked {
		if row.Block == rcxBlockNone {
			eligible++
		}
	}
	status := rcxStatus{
		Enabled:    e.Enabled(),
		Preset:     e.cfg.Preset,
		Mode:       e.runtime.Mode(),
		Terrain:    e.terrainCurrent().String(),
		Env:        e.envKey,
		Node:       e.incumbent,
		DelayMs:    e.delayOf(e.incumbent),
		Reason:     string(reason),
		Searching:  e.probing && e.probeLane == "",
		Deep:       e.deep,
		Pinned:     input.Pin != "",
		PinNode:    input.Pin,
		Direct:     e.direct,
		Candidates: len(ranked),
		Eligible:   eligible,
		SwitchedAt: rcxMillis(e.switchedAt),
		Lanes:      e.laneStatuses(),
		Link: rcxLinkReport{
			Transport: e.transport,
			Validated: e.validated,
			Portal:    e.portal,
			Metered:   e.metered,
			Foreign:   rcxOutcomeName(e.reachF),
			Domestic:  rcxOutcomeName(e.reachD),
			SNI:       rcxOutcomeName(e.reachS),
			Since:     rcxMillis(e.terrain.since),
		},
	}
	report := rcxReport{
		Status:     status,
		Link:       status.Link,
		Canaries:   append([]rcxCanaryReport(nil), e.canaries...),
		History:    append([]rcxSwitchReport(nil), e.history...),
		Metrics:    e.metricsReport(now),
		Bands:      e.cfg.latencyBands(),
		Ladder:     rcxLadderForStrategy(input.Policy.ladderOrDefault(), input.Policy.Strategy),
		ProbesLeft: e.budget.Remaining(now),
		ProbeCap:   rcxProbeBudgetCap,
		Manual:     input.Pin != "",
		Discovery:  e.discoveryReport(),
		At:         rcxMillis(now),
	}

	e.mu.Lock()
	changed := !reflect.DeepEqual(e.status, status)
	e.status = status
	e.report = report
	e.reportRanked = append(e.reportRanked[:0], ranked...)
	e.reportInput = input
	e.reportVersion++
	e.mu.Unlock()
	if changed {
		e.runtime.Publish(status)
	}
	e.recordDecision(reason, ranked, input)
}

func (e *rcxEngine) candidateReports(
	ranked []rcxRanked,
	input rcxDecisionInput,
	now time.Time,
) []rcxCandidateReport {
	rows := make([]rcxCandidateReport, 0, len(ranked))
	for _, row := range ranked {
		candidate := row.Candidate
		cool := 0
		if !candidate.CoolUntil.IsZero() && now.Before(candidate.CoolUntil) {
			cool = int(candidate.CoolUntil.Sub(now) / time.Second)
		}
		trust, conf := e.ledger.Trust(e.key(candidate.Name))
		// The verdict the rank actually used: user rules can cap it down to
		// last-resort, and the duel must explain that verdict, not the raw one.
		verdict := rcxCandidateVerdict(candidate, input.Terrain)
		// The latency the rank actually used, so the duel never inverts the
		// order again. Anything at or above the unmeasured penalty base is not
		// a latency at all: it maps to -1 (unknown) on the wire, never to a raw
		// host ping that reads "fastest" for a node ranked last.
		rankMs := row.Key.latencyMs
		if rankMs >= rcxUnmeasuredLatencyBase {
			rankMs = -1
		}
		rows = append(rows, rcxCandidateReport{
			Node:       candidate.Name,
			Country:    e.ledger.DisplayCountry(e.key(candidate.Name)),
			Exit:       e.freshExitCountry(e.key(candidate.Name), now),
			Origin:     candidate.Facts.Origin.String(),
			Verdict:    verdict.String(),
			Evidence:   candidate.Evidence.String(),
			Block:      string(row.Block),
			MedianMs:   candidate.MedianMs,
			HostMs:     candidate.HostMs,
			Band:       int(row.Key.latBucket),
			LatencyMs:  rcxDiscoveryLatency(candidate),
			RankMs:     rankMs,
			Unproven:   row.Key.unproven,
			Order:      candidate.Order,
			Prefer:     candidate.Prefer,
			RuleCapped: candidate.RuleLastResort && verdict == rcxVerdictLastResort,
			Breaker:    candidate.Facts.Breaker,
			Degraded:   candidate.Degraded,
			HomeRisk:   int(row.Key.homeRisk),
			Recurrence: candidate.Recurrence,
			Confirmed:  candidate.QualityConfirmed,
			UDP:        candidate.Facts.SupportsUDP,
			Fails:      e.ledger.FailStreak(e.key(candidate.Name), e.envKey),
			CoolFor:    cool,
			Current:    candidate.Name == e.incumbent,
			Trust:      trust.String(),
			Confidence: conf.String(),
		})
	}
	return rows
}
