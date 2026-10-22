package rcx

import (
	"slices"
	"strings"
	"time"
)

const (
	maxSamples       = 8
	maxEpisodes      = 16
	maxEnvironments  = 16
	episodeWindow    = 24 * time.Hour
	sampleWindow     = 6 * time.Hour
	dialFailWindow   = 20 * time.Second
	suspectDialFails = 3
	baseFreshness    = 45 * time.Minute
	stableFreshness  = 3 * time.Hour
	stableNetwork    = 2 * time.Hour
	checkWindow      = 6 * time.Hour
	exitTTL          = 24 * time.Hour
	exitRetry        = 2 * time.Hour
)

type Source string

const (
	TrafficSource Source = "traffic"
	ProbeSource   Source = "probe"
	TestSource    Source = "test"
)

type Sample struct {
	At time.Time `json:"at"`
	Ms int       `json:"ms"`
}

// Facts is what is known about one node on one network. Every value carries
// the time it was learned; nothing is a bare flag.
type Facts struct {
	Samples   []Sample              `json:"samples,omitempty"`
	OKAt      time.Time             `json:"okAt,omitzero"`
	OKSource  Source                `json:"okSource,omitempty"`
	FailAt    time.Time             `json:"failAt,omitzero"`
	FailRun   int                   `json:"failRun,omitempty"`
	DeadAt    time.Time             `json:"deadAt,omitzero"`
	Episodes  []time.Time           `json:"episodes,omitempty"`
	Checks    map[string]*CheckFact `json:"checks,omitempty"`
	dialFails []time.Time
}

// CheckFact is the latest outcome of one declared check and how many times
// in a row it came out that way.
type CheckFact struct {
	At       time.Time `json:"at"`
	OK       bool      `json:"ok"`
	Run      int       `json:"run"`
	PassedAt time.Time `json:"passedAt,omitzero"`
	// Soft: an optional check failed, which is no evidence either way.
	Soft bool `json:"soft,omitempty"`
}

// verdict needs a second failure to overturn a pass, so one dropped request
// never moves a node down a tier; until then the check is unknown.
func (c *CheckFact) verdict(now time.Time) tri {
	switch {
	case c == nil || now.Sub(c.At) > checkWindow:
		return triUnknown
	case c.OK:
		return triYes
	case c.Soft:
		return triNeither
	case c.Run < 2 && !c.PassedAt.IsZero():
		return triUnknown
	default:
		return triNo
	}
}

func (f *Facts) noteCheck(id string, at time.Time, ok, optional bool) {
	if f.Checks == nil {
		f.Checks = map[string]*CheckFact{}
	}
	c := f.Checks[id]
	if c == nil {
		c = &CheckFact{}
		f.Checks[id] = c
	}
	if c.Run > 0 && c.OK == ok {
		c.Run++
	} else {
		c.Run = 1
	}
	c.At, c.OK, c.Soft = at, ok, !ok && optional
	if ok {
		c.PassedAt = at
	}
}

// ExitFact is where a node's traffic leaves, global to the node: an empty
// country is a verification that did not agree.
type ExitFact struct {
	Country string    `json:"country,omitempty"`
	At      time.Time `json:"at"`
	Sources int       `json:"sources,omitempty"`
}

func (x *ExitFact) country(now time.Time) string {
	if x == nil || now.Sub(x.At) > exitTTL {
		return ""
	}
	return x.Country
}

func (x *ExitFact) due(now time.Time) bool {
	switch {
	case x == nil:
		return true
	case x.Country == "":
		return now.Sub(x.At) > exitRetry
	default:
		return now.Sub(x.At) > exitTTL
	}
}

// ExitVote is one source's answer about a node's exit country.
type ExitVote struct {
	Source  string `json:"source"`
	Country string `json:"country"`
}

// exitVerdict accepts a country only when enough distinct sources name it
// and no source names another.
func exitVerdict(votes []ExitVote, agree int) (string, int) {
	sources := map[string]map[string]bool{}
	for _, v := range votes {
		code := strings.ToUpper(strings.TrimSpace(v.Country))
		if !isCountryCode(code) {
			continue
		}
		if sources[code] == nil {
			sources[code] = map[string]bool{}
		}
		sources[code][v.Source] = true
	}
	if len(sources) != 1 {
		return "", 0
	}
	for code, from := range sources {
		if len(from) >= agree {
			return code, len(from)
		}
	}
	return "", 0
}

// isCountryCode accepts ISO 3166-1 alpha-2 codes only; XX, T1 (Tor) and EU
// say nothing about a country.
func isCountryCode(code string) bool {
	if len(code) != 2 || code == "XX" || code == "T1" || code == "EU" {
		return false
	}
	return code[0] >= 'A' && code[0] <= 'Z' && code[1] >= 'A' && code[1] <= 'Z'
}

func (f *Facts) Dead() bool {
	return !f.DeadAt.IsZero() && !f.OKAt.After(f.DeadAt)
}

func (f *Facts) AliveSince(cutoff time.Time) bool {
	return !f.Dead() && f.OKAt.After(cutoff) && !f.FailAt.After(f.OKAt)
}

func (f *Facts) Latency(now time.Time) (p50, spread int, ok bool) {
	var values []int
	for _, s := range f.Samples {
		if s.Ms > 0 && now.Sub(s.At) < sampleWindow {
			values = append(values, s.Ms)
		}
	}
	if len(values) == 0 {
		return 0, 0, false
	}
	slices.Sort(values)
	p50 = values[len(values)/2]
	p90 := values[min(len(values)-1, len(values)*9/10)]
	return p50, p90 - p50, true
}

func (f *Facts) LastSampleAt() time.Time {
	if len(f.Samples) == 0 {
		return time.Time{}
	}
	return f.Samples[len(f.Samples)-1].At
}

func (f *Facts) RecentEpisodes(now time.Time) int {
	count := 0
	for _, at := range f.Episodes {
		if now.Sub(at) < episodeWindow {
			count++
		}
	}
	return count
}

func (f *Facts) noteOK(at time.Time, source Source) {
	if at.After(f.OKAt) {
		f.OKAt, f.OKSource = at, source
	}
	f.FailRun = 0
	f.dialFails = f.dialFails[:0]
}

func (f *Facts) noteSample(at time.Time, ms int, source Source) {
	f.noteOK(at, source)
	f.Samples = append(f.Samples, Sample{At: at, Ms: ms})
	if len(f.Samples) > maxSamples {
		f.Samples = slices.Delete(f.Samples, 0, len(f.Samples)-maxSamples)
	}
}

// noteProbeFail records a failed check. The node is not dead yet: the engine
// confirms a death only once it has ruled out the link (see escrow in engine).
func (f *Facts) noteProbeFail(at time.Time) {
	f.FailAt = at
	f.FailRun++
}

func (f *Facts) markDead(at time.Time) {
	if f.Dead() {
		return
	}
	f.DeadAt = at
	f.Episodes = append(f.Episodes, at)
	if len(f.Episodes) > maxEpisodes {
		f.Episodes = slices.Delete(f.Episodes, 0, len(f.Episodes)-maxEpisodes)
	}
}

// noteDialFail reports whether real traffic now suspects the node: several
// failed dials in a short window with no success between them.
func (f *Facts) noteDialFail(at time.Time) bool {
	kept := f.dialFails[:0]
	for _, t := range f.dialFails {
		if at.Sub(t) < dialFailWindow {
			kept = append(kept, t)
		}
	}
	f.dialFails = append(kept, at)
	return len(f.dialFails) >= suspectDialFails && !f.OKAt.After(f.dialFails[0])
}

type Environment struct {
	SeenAt time.Time         `json:"seenAt"`
	Since  time.Time         `json:"since"`
	Nodes  map[string]*Facts `json:"nodes"`
	// Diag holds the latest outcome per direct diagnostic target, Kinds the
	// confirmed network kind per policy: the memory of this network.
	Diag  map[string]DiagFact `json:"diag,omitempty"`
	Kinds map[string]string   `json:"kinds,omitempty"`
}

type DiagFact struct {
	At time.Time `json:"at"`
	OK bool      `json:"ok"`
}

// diagnosis reads one named diagnostic: it holds when any target answered,
// fails when every target was tried and none did.
func (env *Environment) diagnosis(targets []Target) tri {
	out := triNo
	for _, target := range targets {
		fact, ok := env.Diag[target.String()]
		switch {
		case ok && fact.OK:
			return triYes
		case !ok:
			out = triUnknown
		}
	}
	return out
}

func (env *Environment) facts(key string) *Facts {
	f := env.Nodes[key]
	if f == nil {
		f = &Facts{}
		env.Nodes[key] = f
	}
	return f
}

// Freshness follows network stability: a network that has not changed for a
// while keeps its knowledge longer.
func (env *Environment) Freshness(now time.Time) time.Duration {
	if now.Sub(env.Since) >= stableNetwork {
		return stableFreshness
	}
	return baseFreshness
}

type Evidence struct {
	Envs  map[string]*Environment `json:"envs"`
	Exits map[string]*ExitFact    `json:"exits,omitempty"`
}

func (e *Evidence) env(key string, now time.Time) *Environment {
	if e.Envs == nil {
		e.Envs = map[string]*Environment{}
	}
	env := e.Envs[key]
	if env == nil {
		env = &Environment{Since: now, Nodes: map[string]*Facts{}}
		e.Envs[key] = env
		e.evict()
	}
	if env.Nodes == nil {
		env.Nodes = map[string]*Facts{}
	}
	env.SeenAt = now
	return env
}

func (e *Evidence) evict() {
	for len(e.Envs) > maxEnvironments {
		oldest := ""
		for key, env := range e.Envs {
			if oldest == "" || env.SeenAt.Before(e.Envs[oldest].SeenAt) {
				oldest = key
			}
		}
		delete(e.Envs, oldest)
	}
}

// prune drops facts for nodes the identity index has forgotten.
func (e *Evidence) prune(live map[string]bool) {
	for key := range e.Exits {
		if !live[key] {
			delete(e.Exits, key)
		}
	}
	for _, env := range e.Envs {
		for key := range env.Nodes {
			if !live[key] {
				delete(env.Nodes, key)
			}
		}
	}
}
