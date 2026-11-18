package core

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"net/netip"
	"runtime"
	"slices"
	"strings"
	"sync/atomic"

	"core/sitelock"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/geodata"
	"github.com/metacubex/mihomo/component/geodata/router"
	"github.com/metacubex/mihomo/component/sniffer"
	C "github.com/metacubex/mihomo/constant"
	snifferTypes "github.com/metacubex/mihomo/constant/sniffer"
	"github.com/metacubex/mihomo/listener"
	"github.com/metacubex/mihomo/tunnel"
)

type siteLockState struct {
	set      *sitelock.Set
	problems []sitelock.Problem
	names    sitelock.Names
	guarded  []sitelock.GuardedNames
	namesSum [sha256.Size]byte
	partial  []string
}

var siteLocks atomic.Pointer[siteLockState]

// Not the config's REJECT: the fallback config of a failed apply must refuse too.
var siteLockRefusal = adapter.NewProxy(outbound.NewReject())

var siteLockEnv = sitelock.Env{
	Proxies: tunnel.AllProxies,
	Alive:   func(proxy C.Proxy) bool { return proxy.AliveForTestUrl(currentTestURL()) },
	Refuse:  func() C.Proxy { return siteLockRefusal },
}

type SiteLockReport struct {
	Applied  bool               `json:"applied"`
	Problems []sitelock.Problem `json:"problems"`
	Locks    []sitelock.State   `json:"locks"`
	Warnings []sitelock.Warning `json:"warnings"`
}

func init() {
	registerMethod(siteLockPolicyMethod, withArguments(func(params siteLockPolicyParams) *SiteLockPolicy {
		return siteLockPolicy(params.Known)
	}))
	registerMethod(setSiteLocksMethod, withFallible(func(locks []sitelock.Lock) (SiteLockReport, error) {
		return setSiteLocks(locks), nil
	}))
	registerMethod(siteLockStatusMethod, func(*MethodCall) (any, error) {
		return siteLockReport(true, nil), nil
	})
	registerMethod(siteLockExitsMethod, func(*MethodCall) (any, error) {
		return sitelock.Candidates(tunnel.AllProxies()), nil
	})
}

func siteLockClaim(metadata *C.Metadata, helper C.RuleMatchHelper) (C.Proxy, C.Rule) {
	state := siteLocks.Load()
	if state == nil {
		return nil, nil
	}
	proxy, rule, _ := state.set.Claim(metadata, helper, siteLockEnv)
	return proxy, rule
}

// A failed edit keeps the locks in force rather than dropping one.
func setSiteLocks(locks []sitelock.Lock) SiteLockReport {
	set, problems := sitelock.Compile(locks)
	if len(problems) > 0 {
		return siteLockReport(false, problems)
	}
	storeSiteLocks(&siteLockState{set: set})
	configMu.Lock()
	syncSiteLockSniffer()
	configMu.Unlock()
	return siteLockReport(true, nil)
}

// Set while the lock's own sniffer stands in for a config that sniffs nothing.
// Guarded by configMu.
var siteLockSniffing bool

func siteLockSnifferConfig() *sniffer.Config {
	ports := func(list ...string) utils.IntRanges[uint16] {
		ranges, _ := utils.NewUnsignedRangesFromList[uint16](list)
		return ranges
	}
	return &sniffer.Config{
		Enable:      true,
		ParsePureIp: true,
		Sniffers: map[snifferTypes.Type]sniffer.SnifferConfig{
			snifferTypes.TLS:  {Ports: ports("443", "8443")},
			snifferTypes.HTTP: {Ports: ports("80", "8080-8880")},
			snifferTypes.QUIC: {Ports: ports("443", "8443")},
		},
	}
}

// Domain entries see only named connections, and one that reached the core
// as a bare address (browser DoH, a cached answer) is named only by sniffing,
// so a config without a sniffer gets one while a domain lock is on. A config
// that sniffs keeps its own. Runs with configMu held.
func syncSiteLockSniffer() {
	if currentConfig == nil {
		siteLockSniffing = false
		return
	}
	own := currentConfig.Sniffer
	if own == nil {
		own = &sniffer.Config{}
	}
	state := siteLocks.Load()
	want := !own.Enable && state != nil && len(state.set.Named()) > 0
	if want == siteLockSniffing {
		return
	}
	next := own
	if want {
		next = siteLockSnifferConfig()
	}
	dispatcher, err := sniffer.NewDispatcher(next)
	if err != nil {
		logError("site lock sniffer not applied: %v", err)
		return
	}
	tunnel.UpdateSniffer(dispatcher)
	siteLockSniffing = want
}

// Runs before the listeners are rebuilt; a setup cannot be refused, so a broken lock is only reported.
func applySetupSiteLocks(locks *[]sitelock.Lock) {
	if locks == nil {
		return
	}
	set, problems := sitelock.Compile(*locks)
	for _, problem := range problems {
		logError("site lock %q not enforced, %s: %s", problem.ID, problem.Field, problem.Message)
	}
	storeSiteLocks(&siteLockState{set: set, problems: problems})
}

// GEOSITE entries hold the lists loaded at compile time, so a new database
// needs a fresh compile; one that loses a list keeps the locks as they were.
func recompileSiteLocks() {
	current := siteLocks.Load()
	if current == nil {
		return
	}
	set, problems := sitelock.Compile(current.set.Locks())
	if len(problems) > 0 {
		for _, problem := range problems {
			logError("site lock %q kept on the previous GeoSite, %s: %s", problem.ID, problem.Field, problem.Message)
		}
		return
	}
	siteLocks.CompareAndSwap(current, withNames(&siteLockState{set: set, problems: current.problems}))
}

func storeSiteLocks(state *siteLockState) {
	siteLocks.Store(withNames(state))
}

// NRPT, the Windows host layer, holds only full names and suffixes.
const hostMatchesPatterns = runtime.GOOS != "windows"

func withNames(state *siteLockState) *siteLockState {
	state.names, state.guarded, state.partial = state.set.Names(loadGeoSite, hostMatchesPatterns)
	encoded, _ := json.Marshal([]any{state.names, state.guarded})
	state.namesSum = sha256.Sum256(encoded)
	return state
}

// SiteLockPolicy is what the OS firewall enforces once the core is gone: the
// addresses and names that may leave only through Tun (empty while TUN is off).
// A host that already holds Revision gets it back Unchanged, without the rest.
type SiteLockPolicy struct {
	Revision  string                  `json:"revision"`
	Unchanged bool                    `json:"unchanged,omitempty"`
	Tun       string                  `json:"tun"`
	Addresses []string                `json:"addresses"`
	Names     *sitelock.Names         `json:"names,omitempty"`
	Guarded   []sitelock.GuardedNames `json:"guarded,omitempty"`
}

type siteLockPolicyParams struct {
	Known string `json:"known"`
}

// Nil until the first locks arrive, so a fresh core cannot lift the firewall.
func siteLockPolicy(known string) *SiteLockPolicy {
	state := siteLocks.Load()
	if state == nil {
		return nil
	}
	prefixes := state.set.Prefixes()
	if !state.names.Empty() || len(state.guarded) > 0 {
		prefixes = append(prefixes, fakeIPRanges()...)
	}
	addresses := make([]string, 0, len(prefixes))
	for _, prefix := range prefixes {
		addresses = append(addresses, prefix.Masked().String())
	}
	slices.Sort(addresses)
	addresses = slices.Compact(addresses)
	tun := siteLockTun()
	digest := sha256.New()
	digest.Write([]byte(tun + "\x00" + strings.Join(addresses, ",") + "\x00"))
	digest.Write(state.namesSum[:])
	revision := hex.EncodeToString(digest.Sum(nil))
	if revision == known {
		return &SiteLockPolicy{Revision: revision, Unchanged: true}
	}
	return &SiteLockPolicy{Revision: revision, Tun: tun, Addresses: addresses, Names: &state.names, Guarded: state.guarded}
}

func siteLockTun() string {
	if conf := listener.GetTunConf(); conf.Enable {
		return conf.Device
	}
	return ""
}

// An app still holding a fake address after a crash must not reach whatever
// the physical network routes it to.
func fakeIPRanges() []netip.Prefix {
	configMu.Lock()
	defer configMu.Unlock()
	if currentConfig == nil || currentConfig.DNS == nil {
		return nil
	}
	var ranges []netip.Prefix
	for _, prefix := range []netip.Prefix{currentConfig.DNS.FakeIPRange, currentConfig.DNS.FakeIPRange6} {
		if prefix.IsValid() {
			ranges = append(ranges, prefix)
		}
	}
	return ranges
}

func loadGeoSite(code string) ([]*router.Domain, error) {
	loader, err := geodata.GetGeoDataLoader(geodata.LoaderName())
	if err != nil {
		return nil, err
	}
	return loader.LoadGeoSite(code)
}

func siteLockReport(applied bool, rejected []sitelock.Problem) SiteLockReport {
	report := SiteLockReport{Applied: applied, Problems: rejected, Locks: []sitelock.State{}, Warnings: []sitelock.Warning{}}
	if state := siteLocks.Load(); state != nil {
		report.Locks = state.set.States(siteLockEnv)
		if rejected == nil {
			report.Problems = state.problems
		}
		if len(state.partial) > 0 {
			report.Warnings = append(report.Warnings, sitelock.Warning{Code: sitelock.WarningCoreOnly, Locks: state.partial})
		}
	}
	if report.Problems == nil {
		report.Problems = []sitelock.Problem{}
	}
	return report
}
