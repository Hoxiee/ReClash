package core

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"runtime"
	"slices"
	"sync"
	"sync/atomic"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/component/age"
	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/config"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
	"go.yaml.in/yaml/v3"
)

const maxPolicyNodes = 4096
const maxPolicyApps = 512
const maxPolicyGroupDepth = 16

var policyPackage = regexp.MustCompile(`^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$`)
var providerPolicyMu sync.Mutex
var activeProviderPolicy atomic.Pointer[providerPolicy]
var providerPolicyEpoch atomic.Uint64
var providerGlobalMode atomic.Bool
var providerPolicyAndroid = runtime.GOOS == "android"

// Stored separately from config.yaml: scripts and controller reloads cannot
// turn the provider's limits into user-editable routing preferences.
type providerPolicy struct {
	Version    int      `json:"version"`
	Restricted bool     `json:"restricted"`
	Allowed    []string `json:"allowed"`
	Apps       []string `json:"apps"`
	NoGlobal   bool     `json:"noGlobal"`
	Blocked    bool     `json:"blocked"`
	Epoch      uint64   `json:"-"`
}

func (p *providerPolicy) enforced() bool {
	return p != nil && (p.Restricted || p.NoGlobal || p.Blocked || len(p.Apps) != 0)
}

func (p *providerPolicy) allowsGlobal() bool {
	return p == nil || !p.Blocked && !p.NoGlobal && (!p.Restricted || len(p.Allowed) != 0)
}

func (p *providerPolicy) allowsRoute(fingerprint string) bool {
	_, allowed := slices.BinarySearch(p.Allowed, fingerprint)
	return fingerprint != "" && allowed
}

func providerPolicyPath() string {
	return filepath.Join(C.Path.HomeDir(), "provider-policy.json")
}

func parseProviderPolicy(data []byte, lockGlobal, lockApps bool) (*providerPolicy, error) {
	raw, err := policyRawConfig(data)
	if err != nil {
		return nil, err
	}
	policy := &providerPolicy{Version: 1}
	if !lockGlobal && !lockApps {
		return policy, nil
	}
	if lockGlobal {
		policy.Restricted = true
		if policy.Allowed, err = policyGlobalRoutes(raw); err != nil {
			return nil, err
		}
	}
	if lockApps {
		if policy.Apps, err = policyStrings(raw.Tun.ExcludePackage, maxPolicyApps, policyPackage); err != nil {
			return nil, err
		}
	}
	return policy, nil
}

// policyGlobalRoutes expands the members of the GLOBAL group down to inline
// proxies. Names that are neither a group nor an inline proxy (provider
// names, DIRECT, REJECT) add nothing, so they stay denied. A pattern that
// cannot be evaluated fails the whole policy rather than narrowing it.
func policyGlobalRoutes(raw *config.RawConfig) ([]string, error) {
	resolver := newGroupResolver(raw)
	var allowed []string
	visited := map[string]bool{}
	var walk func(name string, depth int) error
	walk = func(name string, depth int) error {
		if visited[name] || depth > maxPolicyGroupDepth {
			return nil
		}
		visited[name] = true
		if _, ok := resolver.groups[name]; ok {
			members, err := resolver.members(name)
			if err != nil {
				return err
			}
			for _, member := range members {
				if err := walk(member, depth+1); err != nil {
					return err
				}
			}
			return nil
		}
		if node, ok := resolver.nodes[name]; ok {
			if fingerprint := adapter.RouteFingerprintOf(node); fingerprint != "" {
				allowed = append(allowed, fingerprint)
			}
		}
		return nil
	}
	if _, ok := resolver.groups["GLOBAL"]; ok {
		if err := walk("GLOBAL", 0); err != nil {
			return nil, err
		}
	}
	slices.Sort(allowed)
	allowed = slices.Compact(allowed)
	if len(allowed) > maxPolicyNodes {
		return nil, errors.New("provider GLOBAL node limit exceeded")
	}
	return allowed, nil
}

// providerGlobalNodes is the Core's own view for the app, which cannot run
// regexp2: Dart's RegExp rejects `(?i)` and has ASCII-only `\b` and `\w`.
type providerGlobalNodes struct {
	Allowed int `json:"allowed"`
	Inline  int `json:"inline"`
}

func handleGetProviderGlobalNodes(path string) (providerGlobalNodes, error) {
	data, err := readCoreFile(path)
	if err != nil {
		return providerGlobalNodes{}, err
	}
	raw, err := policyRawConfig(data)
	if err != nil {
		return providerGlobalNodes{}, err
	}
	allowed, err := policyGlobalRoutes(raw)
	if err != nil {
		return providerGlobalNodes{}, err
	}
	routes := map[string]bool{}
	inline := 0
	for _, node := range raw.Proxy {
		fingerprint := adapter.RouteFingerprintOf(node)
		if fingerprint == "" || !routes[fingerprint] {
			inline++
		}
		routes[fingerprint] = true
	}
	return providerGlobalNodes{Allowed: len(allowed), Inline: inline}, nil
}

func policyRawConfig(data []byte) (*config.RawConfig, error) {
	data, err := age.DecryptBytes(data)
	if err != nil {
		return nil, err
	}
	raw := config.DefaultRawConfig()
	if err := yaml.Unmarshal(data, raw); err != nil {
		return nil, err
	}
	return raw, nil
}

func policyStrings(values []string, limit int, pattern *regexp.Regexp) ([]string, error) {
	if len(values) > limit {
		return nil, errors.New("invalid provider policy list")
	}
	result := make([]string, 0, len(values))
	seen := map[string]bool{}
	for _, text := range values {
		if !pattern.MatchString(text) {
			return nil, errors.New("invalid provider policy list entry")
		}
		if !seen[text] {
			seen[text] = true
			result = append(result, text)
		}
	}
	slices.Sort(result)
	return result, nil
}

func loadProviderPolicy(params *SetupParams) (*providerPolicy, error) {
	var policy *providerPolicy
	lockGlobal := params.LockGlobal != nil && *params.LockGlobal
	lockApps := providerPolicyAndroid && params.LockApps != nil && *params.LockApps
	if params.PolicyPath != nil {
		policy = &providerPolicy{Version: 1}
		if *params.PolicyPath != "" {
			data, err := readCoreFile(*params.PolicyPath)
			if err != nil {
				return nil, err
			}
			policy, err = parseProviderPolicy(data, lockGlobal, lockApps)
			if err != nil {
				return nil, err
			}
		}
	} else if current := activeProviderPolicy.Load(); current != nil {
		copy := *current
		policy = &copy
	} else {
		data, err := readCoreFile(providerPolicyPath())
		if errors.Is(err, os.ErrNotExist) {
			data, err = readCoreFile(runningConfigPath())
			if errors.Is(err, os.ErrNotExist) {
				policy = &providerPolicy{Version: 1}
			} else if err == nil {
				policy, err = parseProviderPolicy(data, lockGlobal, lockApps)
			}
		} else if err == nil {
			policy = &providerPolicy{}
			err = json.Unmarshal(data, policy)
			if err == nil && (policy.Version != 1 || len(policy.Allowed) > maxPolicyNodes || len(policy.Apps) > maxPolicyApps) {
				err = errors.New("invalid saved provider policy")
			}
		}
		if err != nil {
			return nil, err
		}
	}
	if params.NoGlobal != nil {
		policy.NoGlobal = *params.NoGlobal
	}
	if len(policy.Apps) != 0 {
		if params.VPNEnabled == nil || !*params.VPNEnabled {
			return nil, errors.New("provider policy requires Android VPN app exclusions")
		}
		for _, app := range policy.Apps {
			if !slices.Contains(params.ExcludedApps, app) {
				return nil, errors.New("provider app exclusions are not applied; restart the VPN")
			}
		}
	}
	return policy, nil
}

func saveProviderPolicy(policy *providerPolicy) error {
	data, err := json.Marshal(policy)
	if err != nil {
		return err
	}
	file, err := createCoreTempFile(C.Path.HomeDir(), ".provider-policy-*.json")
	if err != nil {
		return err
	}
	_, writeErr := file.Write(data)
	err = errors.Join(writeErr, file.Chmod(0o600), file.Close())
	if err == nil {
		err = renameCoreFile(file.Name(), providerPolicyPath())
	}
	if err != nil {
		_ = removeCorePath(file.Name(), false)
	}
	return err
}

func installProviderPolicy(policy *providerPolicy) error {
	providerPolicyMu.Lock()
	defer providerPolicyMu.Unlock()
	if err := saveProviderPolicy(policy); err != nil {
		return err
	}
	policy.Epoch = providerPolicyEpoch.Add(1)
	providerGlobalMode.Store(tunnel.Mode() == tunnel.Global)
	previous := activeProviderPolicy.Swap(policy)
	if policy.enforced() || previous.enforced() {
		closeProviderPolicyConnections()
	}
	return nil
}

func blockProviderPolicy(cause error) error {
	providerPolicyMu.Lock()
	defer providerPolicyMu.Unlock()
	policy := &providerPolicy{Version: 1, Blocked: true, Epoch: providerPolicyEpoch.Add(1)}
	activeProviderPolicy.Store(policy)
	closeProviderPolicyConnections()
	return errors.Join(fmt.Errorf("provider policy: %w", cause), saveProviderPolicy(policy))
}

func closeProviderPolicyConnections() {
	statistic.DefaultManager.Range(func(connection statistic.Tracker) bool {
		_ = connection.Close()
		return true
	})
}

func providerPolicyModeChanged(mode tunnel.TunnelMode) {
	providerPolicyMu.Lock()
	defer providerPolicyMu.Unlock()
	providerGlobalMode.Store(mode == tunnel.Global)
	if policy := activeProviderPolicy.Load(); policy.enforced() {
		copy := *policy
		copy.Epoch = providerPolicyEpoch.Add(1)
		activeProviderPolicy.Store(&copy)
		closeProviderPolicyConnections()
	}
}

func providerPolicyMetadata(metadata *C.Metadata) error {
	if metadata.Type == C.INNER {
		return nil
	}
	policy := activeProviderPolicy.Load()
	if !policy.enforced() {
		return nil
	}
	metadata.PolicyGeneration = policy.Epoch
	metadata.PolicyGlobal = metadata.PolicyGlobal || providerGlobalMode.Load()
	return checkProviderPolicyMetadata(policy, metadata)
}

func checkProviderPolicyMetadata(policy *providerPolicy, metadata *C.Metadata) error {
	if policy.Blocked {
		return errors.New("provider policy could not be applied; reconnect after fixing the profile")
	}
	if metadata.PolicyGeneration != 0 && metadata.PolicyGeneration != policy.Epoch {
		return errors.New("provider policy changed while connecting; retry the connection")
	}
	if len(policy.Apps) != 0 && metadata.Type != C.INNER {
		if metadata.Type != C.TUN {
			return errors.New("provider app policy only permits VPN traffic")
		}
		if metadata.Process == "" {
			name, err := process.FindPackageName(metadata)
			if err != nil || name == "" {
				return errors.New("provider policy could not identify this application")
			}
			metadata.Process = name
		}
		if slices.Contains(policy.Apps, metadata.Process) {
			return errors.New("provider policy requires this application to remain outside the VPN")
		}
	}
	return nil
}

func providerPolicyDial(proxy *adapter.Proxy, metadata *C.Metadata) error {
	policy := activeProviderPolicy.Load()
	if !policy.enforced() {
		return nil
	}
	if err := checkProviderPolicyMetadata(policy, metadata); err != nil {
		return err
	}
	if !metadata.PolicyGlobal && !providerGlobalMode.Load() {
		return nil
	}
	if !policy.Restricted && !policy.NoGlobal {
		return nil
	}
	switch proxy.Type() {
	case C.Selector, C.URLTest, C.Fallback, C.LoadBalance, C.Relay, C.Reject, C.RejectDrop:
		return nil
	}
	if !providerPolicyCandidate(policy, proxy, lookupProxy) {
		return fmt.Errorf("provider policy: node %q is not allowed in GLOBAL", proxy.Name())
	}
	return nil
}

func providerPolicyAdmit(connection statistic.Tracker) bool {
	policy := activeProviderPolicy.Load()
	metadata := connection.Info().Metadata
	if !policy.enforced() || metadata == nil || metadata.Type == C.INNER {
		return true
	}
	if err := checkProviderPolicyMetadata(policy, metadata); err != nil {
		_ = connection.Close()
		return false
	}
	return true
}

func providerGlobalCandidate(proxy C.Proxy) bool {
	return providerPolicyCandidate(activeProviderPolicy.Load(), proxy, lookupProxy)
}

func providerPolicyCandidate(policy *providerPolicy, proxy C.Proxy, lookup func(string) C.Proxy) bool {
	if policy == nil || !policy.Restricted && !policy.NoGlobal && !policy.Blocked {
		return true
	}
	if !policy.allowsGlobal() {
		return false
	}
	seen := map[string]bool{}
	var allowed func(C.Proxy) bool
	allowed = func(proxy C.Proxy) bool {
		if proxy == nil || seen[proxy.Name()] || len(seen) >= 64 {
			return false
		}
		seen[proxy.Name()] = true
		defer delete(seen, proxy.Name())
		if group, ok := adapterAs[interface{ Proxies() []C.Proxy }](proxy); ok {
			members := group.Proxies()
			if len(members) == 0 {
				return false
			}
			for _, member := range members {
				if !allowed(member) {
					return false
				}
			}
			return true
		}
		node, ok := proxy.(*adapter.Proxy)
		if !ok || node.Type() < C.Shadowsocks || !policy.allowsRoute(node.RouteFingerprint()) {
			return false
		}
		dependency := node.ProxyInfo().DialerProxy
		return dependency == "" || allowed(lookup(dependency))
	}
	return allowed(proxy)
}
