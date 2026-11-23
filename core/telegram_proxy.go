package core

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"net"
	"slices"
	"strconv"
	"strings"
	"sync"
	"time"

	"core/telegram"

	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

const telegramSelfTestTimeout = 15 * time.Second

type TelegramProxyParams struct {
	Enabled         bool     `json:"enabled"`
	Port            int      `json:"port"`
	Secret          string   `json:"secret"`
	Endpoints       []string `json:"endpoints"`
	CFDomains       []string `json:"cfDomains"`
	CFWorkerDomains []string `json:"cfWorkerDomains"`
	FakeTLSDomain   string   `json:"fakeTlsDomain"`
	ProxyProtocol   bool     `json:"proxyProtocol"`
	Targets         []string `json:"targets"`
	DisableSecure   bool     `json:"disableSecure"`
	TestDC          bool     `json:"testDC"`
	Outbound        string   `json:"outbound"`
}

type TelegramProxyState struct {
	Running           bool             `json:"running"`
	Error             string           `json:"error,omitempty"`
	OutboundAvailable bool             `json:"outboundAvailable"`
	OutboundName      string           `json:"outboundName,omitempty"`
	Status            *telegram.Status `json:"status,omitempty"`
}

// The relay belongs to the Core's lifetime, not to a run: nothing here reads
// isRunning or the listeners, so it needs neither a profile nor a TUN and
// starting it never touches either.
var telegramProxy struct {
	mu            sync.Mutex
	relay         *telegram.Relay
	listenPort    int
	secret        string
	outbound      string
	fakeTLSDomain string
	proxyProtocol bool
	disableSecure bool
	testDC        bool
	targets       []string
	lastError     string
	appliedSeq    uint64
}

func handleSetTelegramProxy(call *MethodCall) (any, error) {
	params, err := decodeArguments[TelegramProxyParams](call)
	if err != nil {
		return nil, err
	}
	return applyTelegramProxy(params, call.seq), nil
}

func applyTelegramProxy(params TelegramProxyParams, seq uint64) TelegramProxyState {
	p := &telegramProxy
	p.mu.Lock()
	defer p.mu.Unlock()
	if seq < p.appliedSeq {
		return telegramProxyStateLocked()
	}
	p.appliedSeq = seq
	p.lastError = ""
	if !params.Enabled {
		stopTelegramProxyLocked()
		return telegramProxyStateLocked()
	}
	params.FakeTLSDomain = strings.ToLower(strings.TrimSpace(params.FakeTLSDomain))
	secret, err := decodeTelegramSecret(params.Secret)
	if err != nil {
		stopTelegramProxyLocked()
		p.lastError = err.Error()
		return telegramProxyStateLocked()
	}
	targets, err := parseTelegramTargets(params.Targets)
	if err != nil {
		stopTelegramProxyLocked()
		p.lastError = err.Error()
		return telegramProxyStateLocked()
	}
	same := p.relay != nil &&
		p.listenPort == params.Port &&
		p.secret == params.Secret &&
		p.fakeTLSDomain == params.FakeTLSDomain &&
		p.proxyProtocol == params.ProxyProtocol &&
		p.disableSecure == params.DisableSecure &&
		p.testDC == params.TestDC &&
		slices.Equal(p.targets, params.Targets)
	if same {
		p.relay.SetEndpoints(params.Endpoints)
		p.relay.SetCFDomains(params.CFDomains)
		p.relay.SetCFWorkerDomains(params.CFWorkerDomains)
		p.relay.SetTargets(targets)
		if p.outbound != params.Outbound {
			p.outbound = params.Outbound
			p.relay.SetOutbound(dialTelegramOutbound(params.Outbound))
		}
		return telegramProxyStateLocked()
	}
	stopTelegramProxyLocked()
	relay, err := telegram.Start(telegram.Config{
		Listen:          net.JoinHostPort("127.0.0.1", strconv.Itoa(params.Port)),
		Secret:          secret,
		Endpoints:       params.Endpoints,
		CFDomains:       params.CFDomains,
		CFWorkerDomains: params.CFWorkerDomains,
		FakeTLSDomain:   params.FakeTLSDomain,
		ProxyProtocol:   params.ProxyProtocol,
		Targets:         targets,
		DisableSecure:   params.DisableSecure,
		TestDC:          params.TestDC,
		Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
			return dialer.DialContext(ctx, network, address)
		},
		Outbound: dialTelegramOutbound(params.Outbound),
		Logf: func(format string, args ...any) {
			log.Debugln("[Telegram] "+format, args...)
		},
	})
	if err != nil {
		p.lastError = err.Error()
		return telegramProxyStateLocked()
	}
	p.relay = relay
	p.listenPort = params.Port
	p.secret = params.Secret
	p.outbound = params.Outbound
	p.fakeTLSDomain = params.FakeTLSDomain
	p.proxyProtocol = params.ProxyProtocol
	p.disableSecure = params.DisableSecure
	p.testDC = params.TestDC
	p.targets = append([]string(nil), params.Targets...)
	return telegramProxyStateLocked()
}

func parseTelegramTargets(entries []string) (map[int]string, error) {
	targets := make(map[int]string, len(entries))
	for _, entry := range entries {
		entry = strings.TrimSpace(entry)
		if entry == "" {
			continue
		}
		number, address, ok := strings.Cut(entry, ":")
		if !ok {
			return nil, fmt.Errorf("telegram proxy target %q must be dc:host", entry)
		}
		dc, err := strconv.Atoi(strings.TrimSpace(number))
		if err != nil {
			return nil, fmt.Errorf("telegram proxy target %q has no DC number", entry)
		}
		address = strings.TrimSpace(address)
		if address == "" {
			return nil, fmt.Errorf("telegram proxy target %q has no host", entry)
		}
		targets[dc] = address
	}
	if len(targets) == 0 {
		return nil, nil
	}
	return targets, nil
}

func decodeTelegramSecret(value string) ([]byte, error) {
	value = strings.TrimPrefix(value, "dd")
	if strings.HasPrefix(value, "ee") {
		value = value[2:]
		if len(value) < 32 {
			return nil, errors.New("telegram proxy secret must be 32 hex digits")
		}
		value = value[:32]
	}
	secret, err := hex.DecodeString(value)
	if err != nil || len(secret) != 16 {
		return nil, errors.New("telegram proxy secret must be 32 hex digits")
	}
	return secret, nil
}

func stopTelegramProxyLocked() {
	p := &telegramProxy
	if p.relay == nil {
		return
	}
	p.relay.Stop()
	p.relay = nil
	p.secret = ""
}

func telegramProxyStateLocked() TelegramProxyState {
	p := &telegramProxy
	state := TelegramProxyState{
		Error:             p.lastError,
		OutboundAvailable: len(tunnel.AllProxies()) > 0,
	}
	if p.relay == nil {
		return state
	}
	status := p.relay.Status()
	state.Running = true
	state.Status = &status
	if proxy, err := telegramOutbound(p.outbound, telegramProbeAddress); err == nil {
		state.OutboundName = proxy.Name()
	}
	return state
}

func handleGetTelegramProxy() TelegramProxyState {
	telegramProxy.mu.Lock()
	defer telegramProxy.mu.Unlock()
	return telegramProxyStateLocked()
}

// A call that was still in flight when the host shut the Core down must not
// bring the relay back.
func stopTelegramProxy() {
	p := &telegramProxy
	p.mu.Lock()
	defer p.mu.Unlock()
	p.appliedSeq = methodCallSeq.Load() + 1
	stopTelegramProxyLocked()
}

// Sockets opened before a TUN came up or on a network that is gone would only
// time out; Telegram reconnects at once when they close.
func resetTelegramProxyConnections() {
	telegramProxy.mu.Lock()
	relay := telegramProxy.relay
	telegramProxy.mu.Unlock()
	if relay != nil {
		relay.ResetConnections()
	}
}

// An empty outbound leaves the profile unused, so a relay nobody opted in never
// spends subscription traffic; this value picks the profile's rules, and a name
// that cannot collide with a proxy group keeps both in one setting.
const telegramOutboundRules = "@rules"

// DC 5, one of the DCs that only an outbound reaches: rules that route by IP
// range answer for all of them through this address.
const telegramProbeAddress = "91.108.56.130:443"

func telegramOutbound(name, address string) (constant.Proxy, error) {
	if name == "" || len(tunnel.AllProxies()) == 0 {
		return nil, telegram.ErrNoOutbound
	}
	if name != telegramOutboundRules {
		proxy := lookupProxy(name)
		if proxy == nil {
			return nil, fmt.Errorf("outbound %s is not in the active profile: %w", name, telegram.ErrNoOutbound)
		}
		return proxy, nil
	}
	metadata, err := probeMetadata(address)
	if err != nil {
		return nil, err
	}
	return tunnel.ResolveRoute(metadata)
}

func dialTelegramOutbound(name string) telegram.OutboundFunc {
	if name == "" {
		return nil
	}
	return func(ctx context.Context, address string) (net.Conn, error) {
		proxy, err := telegramOutbound(name, address)
		if err != nil {
			return nil, err
		}
		metadata, err := probeMetadata(address)
		if err != nil {
			return nil, err
		}
		return proxy.DialContext(ctx, metadata)
	}
}

// A full round through the listener, the secret and an upstream, which is what
// Telegram does and what nothing short of a real reply can confirm.
func handleTelegramProxySelfTest(dc int16) string {
	p := &telegramProxy
	p.mu.Lock()
	relay, secretHex, fakeTLSDomain := p.relay, p.secret, p.fakeTLSDomain
	p.mu.Unlock()
	if relay == nil {
		return "telegram proxy is not running"
	}
	secret, err := decodeTelegramSecret(secretHex)
	if err != nil {
		return err.Error()
	}
	ctx, cancel := context.WithTimeout(context.Background(), telegramSelfTestTimeout)
	defer cancel()
	address := net.JoinHostPort("127.0.0.1", strconv.Itoa(relay.Port()))
	var testErr error
	if fakeTLSDomain != "" {
		_, testErr = telegram.SelfTestFakeTLS(ctx, address, secret, dc)
	} else {
		_, testErr = telegram.SelfTest(ctx, address, secret, dc)
	}
	if testErr != nil {
		return testErr.Error()
	}
	return ""
}
