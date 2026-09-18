package main

import (
	"fmt"
	"runtime"
	"sort"
	"time"

	"github.com/metacubex/mihomo/constant"
)

const subscriptionReportSchemaVersion = 1

// subscriptionReportTopNodes bounds how many per-node lines the export carries.
// The worst offenders are what a provider acts on; the rest is already summed
// into the bounded byProtocol/byGroup aggregates.
const subscriptionReportTopNodes = 20

// egressLookup returns a node's measured exit country, or "" when unknown. It
// must never trigger a geo query (IPInstance calls os.Exit on Android).
type egressLookup func(node string) string

func buildSubscriptionReport(
	counters subscriptionCounters,
	metadata subscriptionNodeMetadata,
	now time.Time,
	terrain string,
	env string,
	egress egressLookup,
) subscriptionReport {
	report := subscriptionReport{
		SchemaVersion:     subscriptionReportSchemaVersion,
		GeneratedAt:       now.UnixMilli(),
		CoreVersion:       constant.Version,
		Platform:          runtime.GOOS,
		Architecture:      runtime.GOARCH,
		WindowStart:       counters.startedAt.UnixMilli(),
		WindowEnd:         counters.updatedAt.UnixMilli(),
		Terrain:           terrain,
		Env:               env,
		Presets:           metadata.presets,
		DroppedEvents:     counters.droppedEvents,
		ConfigNodeCount:   len(metadata.nodes),
		ObservedNodeCount: len(counters.nodes),
	}

	report.RuntimeDial = subscriptionDialReport{
		Attempts:     counters.dialAttempts,
		Success:      counters.dialSuccess,
		Failure:      counters.dialFailure,
		ByTransport:  outcomeReports(counters.byTransport),
		ByStage:      outcomeReports(counters.byStage),
		ByErrorClass: classReports(counters.byErrClass),
	}

	nodes, protocolOutcomes, groupOutcomes, egressOutcomes := foldNodes(counters, metadata, egress)
	report.RuntimeDial.ByProtocol = outcomeReportsFromMap(protocolOutcomes)
	report.RuntimeDial.ByGroup = groupReportsFromMap(groupOutcomes)
	report.RuntimeDial.ByEgress = outcomeReportsFromMap(egressOutcomes)
	report.Nodes = nodes
	return report
}

// foldNodes derives the breakdowns from every node but lists only top-N
// individually, so aggregates cover the whole park while the list stays bounded.
func foldNodes(
	counters subscriptionCounters,
	metadata subscriptionNodeMetadata,
	egress egressLookup,
) ([]subscriptionNodeReport, map[string]*subscriptionOutcome, map[string]*subscriptionOutcome, map[string]*subscriptionOutcome) {
	byProtocol := map[string]*subscriptionOutcome{}
	byGroup := map[string]*subscriptionOutcome{}
	byEgress := map[string]*subscriptionOutcome{}

	type namedStat struct {
		name string
		stat *subscriptionNodeStat
	}
	all := make([]namedStat, 0, len(counters.nodes))
	for name, stat := range counters.nodes {
		all = append(all, namedStat{name: name, stat: stat})
		label := metadata.nodes[name]

		protocol := label.Protocol
		if protocol == "" {
			protocol = "other"
		}
		addOutcome(byProtocol, protocol, stat.attempts, stat.failures)

		if len(label.Groups) == 0 {
			addOutcome(byGroup, "", stat.attempts, stat.failures)
		}
		for _, group := range label.Groups {
			addOutcome(byGroup, group, stat.attempts, stat.failures)
		}

		country := ""
		if egress != nil {
			country = egress(name)
		}
		if country != "" {
			addOutcome(byEgress, country, stat.attempts, stat.failures)
		}
	}

	sort.Slice(all, func(i, j int) bool {
		return worseNode(all[i].stat, all[j].stat)
	})

	limit := subscriptionReportTopNodes
	if limit > len(all) {
		limit = len(all)
	}
	reports := make([]subscriptionNodeReport, 0, limit)
	for i := 0; i < limit; i++ {
		item := all[i]
		if item.stat.failures == 0 {
			// The list is sorted worst-first; once a healthy node appears the
			// rest are healthy too and belong only in the aggregates.
			break
		}
		label := metadata.nodes[item.name]
		country := ""
		if egress != nil {
			country = egress(item.name)
		}
		reports = append(reports, subscriptionNodeReport{
			Alias:         fmt.Sprintf("node-%02d", i+1),
			Protocol:      label.Protocol,
			Transport:     label.Transport,
			EgressCountry: country,
			Groups:        label.Groups,
			PositionHint:  label.PositionHint,
			Attempts:      item.stat.attempts,
			Failures:      item.stat.failures,
			Successes:     item.stat.attempts - item.stat.failures,
			FailStreak:    item.stat.failStreak,
			DominantClass: dominantClass(item.stat.classCounts),
			DelayBucketMs: doctorDurationBucket(averageDuration(item.stat)),
		})
	}
	return reports, byProtocol, byGroup, byEgress
}

func worseNode(a, b *subscriptionNodeStat) bool {
	ra := failureRatio(a)
	rb := failureRatio(b)
	if ra != rb {
		return ra > rb
	}
	if a.failStreak != b.failStreak {
		return a.failStreak > b.failStreak
	}
	return a.attempts > b.attempts
}

func failureRatio(s *subscriptionNodeStat) float64 {
	if s.attempts == 0 {
		return 0
	}
	return float64(s.failures) / float64(s.attempts)
}

func averageDuration(s *subscriptionNodeStat) time.Duration {
	if s.durationN == 0 {
		return 0
	}
	return s.durationSum / time.Duration(s.durationN)
}

func dominantClass(counts map[string]int) string {
	best := ""
	bestN := 0
	for class, n := range counts {
		if n > bestN || (n == bestN && class < best) {
			best = class
			bestN = n
		}
	}
	return best
}

func addOutcome(m map[string]*subscriptionOutcome, key string, attempts, failures int) {
	o := m[key]
	if o == nil {
		o = &subscriptionOutcome{}
		m[key] = o
	}
	o.attempts += attempts
	o.failures += failures
}

func outcomeReports(m map[string]*subscriptionOutcome) []subscriptionOutcomeReport {
	return outcomeReportsFromMap(m)
}

func outcomeReportsFromMap(m map[string]*subscriptionOutcome) []subscriptionOutcomeReport {
	out := make([]subscriptionOutcomeReport, 0, len(m))
	for key, o := range m {
		out = append(out, subscriptionOutcomeReport{Key: key, Attempts: o.attempts, Failure: o.failures})
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].Failure != out[j].Failure {
			return out[i].Failure > out[j].Failure
		}
		return out[i].Key < out[j].Key
	})
	return out
}

func groupReportsFromMap(m map[string]*subscriptionOutcome) []subscriptionGroupReport {
	out := make([]subscriptionGroupReport, 0, len(m))
	for group, o := range m {
		out = append(out, subscriptionGroupReport{Group: group, Attempts: o.attempts, Failure: o.failures})
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].Failure != out[j].Failure {
			return out[i].Failure > out[j].Failure
		}
		return out[i].Group < out[j].Group
	})
	return out
}

func classReports(m map[string]int) []subscriptionClassReport {
	out := make([]subscriptionClassReport, 0, len(m))
	for class, n := range m {
		out = append(out, subscriptionClassReport{Class: class, Count: n})
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].Count != out[j].Count {
			return out[i].Count > out[j].Count
		}
		return out[i].Class < out[j].Class
	})
	return out
}
