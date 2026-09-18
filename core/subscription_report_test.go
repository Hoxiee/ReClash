package main

import (
	"encoding/json"
	"strings"
	"testing"
	"time"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

func dialFinished(node, network, errorClass string, elapsed time.Duration) tunnel.FlowEvidence {
	return tunnel.FlowEvidence{
		Stage:      tunnel.FlowEvidenceDialFinished,
		Outbound:   node,
		Network:    networkFor(network),
		ErrorClass: errorClass,
		Duration:   elapsed,
		At:         time.Now(),
	}
}

func networkFor(network string) C.NetWork {
	if network == "udp" {
		return C.UDP
	}
	return C.TCP
}

func drainReporter(t *testing.T, reporter *subscriptionReporter) {
	t.Helper()
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		if reporter.Snapshot().dialAttempts > 0 {
			return
		}
		time.Sleep(5 * time.Millisecond)
	}
}

func TestReporterCountsOutcomesAndIgnoresDirect(t *testing.T) {
	reporter := newSubscriptionReporter()
	reporter.Start()
	defer reporter.Stop()

	reporter.ObserveFlow(dialFinished("alpha", "tcp", "", 40*time.Millisecond))
	reporter.ObserveFlow(dialFinished("alpha", "tcp", "reset", 0))
	reporter.ObserveFlow(dialFinished("DIRECT", "tcp", "reset", 0))
	drainReporter(t, reporter)

	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) && reporter.Snapshot().dialAttempts < 2 {
		time.Sleep(5 * time.Millisecond)
	}
	counters := reporter.Snapshot()
	if counters.dialAttempts != 2 {
		t.Fatalf("attempts = %d, want 2 (DIRECT ignored)", counters.dialAttempts)
	}
	if counters.dialFailure != 1 || counters.dialSuccess != 1 {
		t.Fatalf("success/failure = %d/%d, want 1/1", counters.dialSuccess, counters.dialFailure)
	}
	if counters.byErrClass["reset"] != 1 {
		t.Fatalf("reset class = %d, want 1", counters.byErrClass["reset"])
	}
}

func TestBuildReportPseudonymizesAndCapsNodes(t *testing.T) {
	now := time.Now()
	counters := newSubscriptionCounters(now.Add(-time.Minute))
	counters.updatedAt = now
	for i := 0; i < subscriptionReportTopNodes+5; i++ {
		name := "secret-node-" + string(rune('a'+i))
		counters.nodes[name] = &subscriptionNodeStat{
			attempts:    10,
			failures:    10 - i,
			failStreak:  10 - i,
			classCounts: map[string]int{"reset": 10 - i},
		}
		counters.dialAttempts += 10
		counters.dialFailure += 10 - i
	}

	metadata := subscriptionNodeMetadata{
		nodes: map[string]subscriptionNodeLabel{
			"secret-node-a": {Protocol: "vless", Transport: "tcp", Groups: []string{"Germany"}, PositionHint: 3},
		},
		presets: []string{"ru-mobile"},
	}
	report := buildSubscriptionReport(counters, metadata, now, "normal", "ru-home", func(string) string {
		return "DE"
	})

	if len(report.Nodes) > subscriptionReportTopNodes {
		t.Fatalf("nodes = %d, want <= %d", len(report.Nodes), subscriptionReportTopNodes)
	}
	if report.Nodes[0].Alias != "node-01" {
		t.Fatalf("first alias = %q, want node-01", report.Nodes[0].Alias)
	}
	blob, err := json.Marshal(report)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	if strings.Contains(string(blob), "secret-node") {
		t.Fatal("report leaked a real node name")
	}
	if report.Nodes[0].Protocol != "vless" || report.Nodes[0].EgressCountry != "DE" {
		t.Fatalf("labels missing: %+v", report.Nodes[0])
	}
	if report.ConfigNodeCount != 1 {
		t.Fatalf("configNodeCount = %d, want 1", report.ConfigNodeCount)
	}
	if report.ObservedNodeCount != subscriptionReportTopNodes+5 {
		t.Fatalf("observedNodeCount = %d, want %d", report.ObservedNodeCount, subscriptionReportTopNodes+5)
	}
}

func TestBuildReportOmitsHealthyNodesFromList(t *testing.T) {
	now := time.Now()
	counters := newSubscriptionCounters(now.Add(-time.Minute))
	counters.updatedAt = now
	counters.nodes["good"] = &subscriptionNodeStat{attempts: 5, failures: 0, classCounts: map[string]int{}}
	counters.nodes["bad"] = &subscriptionNodeStat{attempts: 8, failures: 5, failStreak: 5, classCounts: map[string]int{"timeout": 5}}
	counters.dialAttempts = 13
	counters.dialFailure = 5

	report := buildSubscriptionReport(counters, subscriptionNodeMetadata{}, now, "", "", nil)
	if len(report.Nodes) != 1 {
		t.Fatalf("nodes = %d, want 1 (healthy omitted)", len(report.Nodes))
	}
	if report.Nodes[0].DominantClass != "timeout" {
		t.Fatalf("dominant class = %q, want timeout", report.Nodes[0].DominantClass)
	}
	if report.Nodes[0].Successes != 3 {
		t.Fatalf("successes = %d, want 3 (8 attempts - 5 failures)", report.Nodes[0].Successes)
	}
	if report.ObservedNodeCount != 2 {
		t.Fatalf("observedNodeCount = %d, want 2 (healthy counted too)", report.ObservedNodeCount)
	}
}
