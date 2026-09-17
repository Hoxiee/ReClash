package main

import (
	"context"
	"crypto/sha1"
	"encoding/hex"
	"errors"
	"io"
	"net"
	"net/http"
	"net/netip"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/ca"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
	mihomoTLS "github.com/metacubex/tls"
)

const (
	rcxResolveTimeout = 3 * time.Second
	rcxResolveRetry   = 10 * time.Minute
	rcxMmdbRecheck    = time.Minute
	rcxLocateTimeout  = 6 * time.Second
	rcxLocateBodyCap  = 256
	rcxHostProbeDial  = 3 * time.Second
)

var errEchoScheme = errors.New("rcx: echo url needs http or https")

const rcxHostDelayUnknown = 0xffff

const (
	rcxGroupPrefix = "RCX-"
	rcxGroupNode   = "RCX-NODE"
	rcxGroupFinal  = "RCX-FINAL"
	rcxGroupDirect = "RCX-DIRECT"
)

type rcxCoreRuntime struct{}

type rcxNodeLister interface {
	Proxies() []constant.Proxy
}

type rcxNodeReporter interface {
	Now() string
}

func rcxGroupAdapter(name string) (*adapter.Proxy, bool) {
	group := lookupProxy(name)
	if group == nil {
		return nil, false
	}
	proxy, ok := group.(*adapter.Proxy)
	return proxy, ok
}

func rcxNodeGroupAdapter() (*adapter.Proxy, bool) {
	return rcxGroupAdapter(rcxGroupNode)
}

func rcxSelectorMembers(name string) ([]string, bool) {
	proxy, ok := rcxGroupAdapter(name)
	if !ok {
		return nil, false
	}
	selector, ok := proxy.ProxyAdapter.(*outboundgroup.Selector)
	if !ok {
		return nil, false
	}
	proxies := selector.Proxies()
	names := make([]string, len(proxies))
	for i, proxy := range proxies {
		names[i] = proxy.Name()
	}
	return names, len(names) > 0
}

func rcxMembersEqual(got []string, want ...string) bool {
	if len(got) != len(want) {
		return false
	}
	for i := range want {
		if got[i] != want[i] {
			return false
		}
	}
	return true
}

func (rcxCoreRuntime) TopologyValid(config rcxConfig) bool {
	if _, ok := rcxSelectorMembers(rcxGroupNode); !ok {
		return false
	}
	direct, ok := rcxSelectorMembers(rcxGroupDirect)
	if !ok || !rcxMembersEqual(direct, "DIRECT", rcxGroupNode) {
		return false
	}
	final, ok := rcxSelectorMembers(rcxGroupFinal)
	if !ok || !rcxMembersEqual(final, rcxGroupNode, "DIRECT") {
		return false
	}
	for _, lane := range config.Lanes {
		members, ok := rcxSelectorMembers(lane.Group)
		if !ok || members[0] != "REJECT" {
			return false
		}
		hasMain := len(members) > 1 && members[1] == rcxGroupNode
		if hasMain != (lane.Fallback == rcxLaneFallbackMain) {
			return false
		}
		for _, member := range members[1:] {
			if lane.Fallback == rcxLaneReject && member == rcxGroupNode {
				return false
			}
		}
	}
	return true
}

// Placeholders that keep index 0 of the skeleton meaningful are not candidates.
func rcxRoutableNode(proxy constant.Proxy) bool {
	switch proxy.Type() {
	case constant.Direct, constant.Reject, constant.RejectDrop, constant.Pass, constant.Compatible:
		return false
	default:
		return true
	}
}

func (rcxCoreRuntime) Members() []rcxMember {
	proxy, ok := rcxNodeGroupAdapter()
	if !ok {
		return nil
	}
	lister, ok := proxy.ProxyAdapter.(rcxNodeLister)
	if !ok {
		return nil
	}
	nodes := lister.Proxies()
	identities := rcxRouteKeys(nodes)
	url := currentTestURL()
	members := make([]rcxMember, 0, len(nodes))
	for _, node := range nodes {
		if !rcxRoutableNode(node) {
			continue
		}
		hostMs, hostDead, hostAt := rcxHostDelayInfo(node, url)
		info := node.ProxyInfo()
		provider := strings.TrimSpace(info.ProviderName)
		if provider == "" {
			provider = "inline:" + node.Type().String()
		}
		members = append(members, rcxMember{
			Name:             node.Name(),
			ID:               identities[node],
			Ingress:          rcxIngress(node.Addr()),
			ExternalProvider: strings.TrimSpace(info.ProviderName) != "",
			Provider:         provider,
			Transport:        info.DiversityFingerprint,
			Type:             node.Type().String(),
			Port:             rcxPortOf(node.Addr()),
			SupportsUDP:      node.SupportUDP(),
			HostMs:           hostMs,
			HostAt:           hostAt,
			HostDead:         hostDead,
			Order:            len(members),
		})
	}
	return members
}

// The delay test the user runs by hand already covers the whole park, which no
// probe budget can. A missing entry is silence, not a verdict: mihomo folds
// every test URL into one global alive flag, so only a record here condemns.
func rcxHostDelay(node constant.Proxy, url string) (int, bool) {
	delay, dead, _ := rcxHostDelayInfo(node, url)
	return delay, dead
}

func rcxHostDelayInfo(node constant.Proxy, url string) (int, bool, time.Time) {
	state, recorded := node.ExtraDelayHistories()[url]
	if !node.AliveForTestUrl(url) {
		return 0, recorded, rcxLastDelayAt(state.History)
	}
	delay, dead := rcxHostDelayValue(node.LastDelayForTestUrl(url))
	return delay, dead, rcxLastDelayAt(state.History)
}

func rcxLastDelayAt(history []constant.DelayHistory) time.Time {
	if len(history) == 0 {
		return time.Time{}
	}
	return history[len(history)-1].Time
}

func rcxHostDelayValue(delay uint16) (int, bool) {
	if delay == rcxHostDelayUnknown || delay < rcxHarvestFloorMs {
		return 0, false
	}
	return int(delay), false
}

// A refresh renames the whole park, and a name-keyed identity loses every proof.
func rcxNodeKey(kind, address, salt string) string {
	host := rcxHostOf(address)
	if host == "" {
		return ""
	}
	sum := sha1.Sum([]byte(kind + "|" + host + "|" + strconv.Itoa(rcxPortOf(address)) + "|" + salt))
	return hex.EncodeToString(sum[:])[:12]
}

// Two accounts on one endpoint are one key, which would pool their measurements.
func rcxSeparateCollisions(members []rcxMember) []rcxMember {
	seen := make(map[string]int, len(members))
	for _, member := range members {
		if member.ID != "" {
			seen[member.ID]++
		}
	}
	for i := range members {
		if members[i].ID != "" && seen[members[i].ID] > 1 {
			members[i].ID = ""
		}
	}
	return members
}

func rcxPortOf(address string) int {
	_, port, err := net.SplitHostPort(address)
	if err != nil {
		return 0
	}
	value, err := strconv.Atoi(port)
	if err != nil {
		return 0
	}
	return value
}

func rcxHostOf(address string) string {
	host, _, err := net.SplitHostPort(address)
	if err != nil {
		return strings.TrimSpace(address)
	}
	return host
}

func (rcxCoreRuntime) Selected() string {
	proxy, ok := rcxNodeGroupAdapter()
	if !ok {
		return ""
	}
	reporter, ok := proxy.ProxyAdapter.(rcxNodeReporter)
	if !ok {
		return ""
	}
	return reporter.Now()
}

func (rcxCoreRuntime) Select(node string) error {
	return selectGroupMember(rcxGroupNode, node)
}

func (rcxCoreRuntime) SelectedIn(group string) string {
	proxy, ok := rcxGroupAdapter(group)
	if !ok {
		return ""
	}
	reporter, ok := proxy.ProxyAdapter.(rcxNodeReporter)
	if !ok {
		return ""
	}
	return reporter.Now()
}

func (rcxCoreRuntime) SelectIn(group, node string) error {
	return selectGroupMember(group, node)
}

func selectGroupMember(group, node string) error {
	selectMu.Lock()
	defer selectMu.Unlock()

	proxy, ok := rcxGroupAdapter(group)
	if !ok {
		return errGroupNotFound
	}
	selector, ok := proxy.ProxyAdapter.(outboundgroup.SelectAble)
	if !ok {
		return errGroupNotSelect
	}
	return selector.Set(node)
}

func (rcxCoreRuntime) SampleLink() (rcxNetworkPayload, bool) {
	return rcxSampleLink()
}

func (rcxCoreRuntime) Mode() string {
	return tunnel.Mode().String()
}

type rcxResolvedHost struct {
	addr    netip.Addr
	at      time.Time
	pending bool
}

var (
	rcxResolveMu    sync.Mutex
	rcxResolveHosts = map[string]rcxResolvedHost{}
)

// Cache only: this runs on the decision loop, and resolving a park of hostnames
// inline would freeze the tick; a kept failure would strand them all session.
func rcxResolveHost(host string) netip.Addr {
	if literal, err := netip.ParseAddr(host); err == nil {
		return literal
	}
	now := time.Now()
	rcxResolveMu.Lock()
	defer rcxResolveMu.Unlock()
	entry, known := rcxResolveHosts[host]
	if entry.addr.IsValid() {
		return entry.addr
	}
	if entry.pending || (known && now.Sub(entry.at) < rcxResolveRetry) {
		return netip.Addr{}
	}
	rcxResolveHosts[host] = rcxResolvedHost{at: entry.at, pending: true}
	go rcxResolveAsync(host)
	return netip.Addr{}
}

var rcxResolveIP = resolver.ResolveIP

func rcxResolveAsync(host string) {
	ctx, cancel := context.WithTimeout(context.Background(), rcxResolveTimeout)
	address, err := rcxResolveIP(ctx, host)
	cancel()
	if err != nil || !address.IsValid() {
		address = netip.Addr{}
	}
	rcxResolveMu.Lock()
	rcxResolveHosts[host] = rcxResolvedHost{addr: address, at: time.Now()}
	rcxResolveMu.Unlock()
}

var (
	rcxMmdbMu      sync.Mutex
	rcxMmdbOK      bool
	rcxMmdbCheckAt time.Time
)

// A geo update resets that sync.Once, so the guard has to run again — just not
// once per node per tick, since each run opens and parses the database.
func rcxMmdbUsable(now time.Time) bool {
	rcxMmdbMu.Lock()
	defer rcxMmdbMu.Unlock()
	if !rcxMmdbCheckAt.IsZero() && now.Sub(rcxMmdbCheckAt) < rcxMmdbRecheck {
		return rcxMmdbOK
	}
	rcxMmdbOK = mmdb.Verify(constant.Path.MMDB())
	rcxMmdbCheckAt = now
	return rcxMmdbOK
}

// mmdb.IPInstance() calls log.Fatalln behind a sync.Once when the file is
// missing or truncated, which would take the whole foreground service down.
func (rcxCoreRuntime) Country(node string) string {
	proxy := lookupProxy(node)
	if proxy == nil {
		return ""
	}
	address := rcxResolveHost(rcxHostOf(proxy.Addr()))
	if !address.IsValid() {
		return ""
	}
	if !rcxMmdbUsable(time.Now()) {
		return ""
	}
	codes := mmdb.IPInstance().LookupCode(address.AsSlice())
	if len(codes) == 0 {
		return ""
	}
	return strings.ToUpper(codes[0])
}

// Where the traffic leaves, not where the tunnel starts: a relay-fronted node
// advertises the front's address, so Country() can read US for a node whose
// packets egress at home. Only an echo through the node itself sees the exit.
func (rcxCoreRuntime) Locate(ctx context.Context, node, echo string) string {
	proxy, ok := lookupProxy(node).(*adapter.Proxy)
	if !ok {
		return ""
	}
	address := rcxEchoAddress(ctx, proxy, echo)
	if !address.IsValid() || !rcxMmdbUsable(time.Now()) {
		return ""
	}
	codes := mmdb.IPInstance().LookupCode(address.AsSlice())
	if len(codes) == 0 {
		return ""
	}
	return strings.ToUpper(codes[0])
}

// The handshake is driven here rather than left to the transport: mihomo builds
// against its own TLS fork, whose config the standard transport will not take.
func rcxEchoAddress(ctx context.Context, proxy *adapter.Proxy, echo string) netip.Addr {
	metadata, err := rcxEchoMetadata(echo)
	if err != nil {
		return netip.Addr{}
	}
	conn, err := proxy.DialContext(ctx, &metadata)
	if err != nil {
		return netip.Addr{}
	}
	defer conn.Close()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, echo, nil)
	if err != nil {
		return netip.Addr{}
	}
	transport := &http.Transport{
		DialContext: func(context.Context, string, string) (net.Conn, error) {
			return conn, nil
		},
		DisableKeepAlives: true,
	}
	if req.URL.Scheme == "https" {
		tlsConfig, err := ca.GetTLSConfig(ca.Option{})
		if err != nil {
			return netip.Addr{}
		}
		tlsConfig.ServerName = req.URL.Hostname()
		tlsConn := mihomoTLS.Client(conn, tlsConfig)
		if err := tlsConn.HandshakeContext(ctx); err != nil {
			return netip.Addr{}
		}
		transport.DialTLSContext = func(context.Context, string, string) (net.Conn, error) {
			return tlsConn, nil
		}
	}
	client := http.Client{
		Transport: transport,
		CheckRedirect: func(*http.Request, []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}
	defer client.CloseIdleConnections()
	resp, err := client.Do(req)
	if err != nil {
		return netip.Addr{}
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return netip.Addr{}
	}
	body, err := io.ReadAll(io.LimitReader(resp.Body, rcxLocateBodyCap))
	if err != nil {
		return netip.Addr{}
	}
	return rcxParseEchoIP(body)
}

func rcxEchoMetadata(echo string) (constant.Metadata, error) {
	parsed, err := url.Parse(echo)
	if err != nil {
		return constant.Metadata{}, err
	}
	port := parsed.Port()
	if port == "" {
		switch parsed.Scheme {
		case "https":
			port = "443"
		case "http":
			port = "80"
		default:
			return constant.Metadata{}, errEchoScheme
		}
	}
	metadata := constant.Metadata{}
	if err := metadata.SetRemoteAddress(net.JoinHostPort(parsed.Hostname(), port)); err != nil {
		return constant.Metadata{}, err
	}
	return metadata, nil
}

// An echo answers with the address alone, but a stray label would parse as one
// too, so a private or loopback token is dropped rather than trusted.
func rcxParseEchoIP(body []byte) netip.Addr {
	text := strings.TrimSpace(string(body))
	if address, err := netip.ParseAddr(text); err == nil && address.IsGlobalUnicast() && !address.IsPrivate() {
		return address
	}
	tokens := strings.FieldsFunc(text, func(char rune) bool {
		return char != '.' && char != ':' &&
			(char < '0' || char > '9') && (char < 'a' || char > 'f') && (char < 'A' || char > 'F')
	})
	for _, token := range tokens {
		address, err := netip.ParseAddr(token)
		if err != nil || !address.IsGlobalUnicast() || address.IsPrivate() {
			continue
		}
		return address
	}
	return netip.Addr{}
}

func (rcxCoreRuntime) Test(
	ctx context.Context,
	node string,
	marker rcxMarker,
) (int, bool, error) {
	proxy, ok := lookupProxy(node).(*adapter.Proxy)
	if !ok {
		return 0, false, errGroupNotFound
	}
	expected, err := rcxExpectedStatuses(marker.Statuses)
	if err != nil {
		return 0, false, err
	}
	delay, satisfied, err := proxy.URLTestStatus(ctx, marker.URL, expected)
	return int(delay), satisfied, err
}

func rcxExpectedStatuses(statuses []int) (utils.IntRanges[uint16], error) {
	if len(statuses) == 0 {
		return nil, nil
	}
	list := make([]string, 0, len(statuses))
	for _, status := range statuses {
		list = append(list, strconv.Itoa(status))
	}
	return utils.NewUnsignedRangesFromList[uint16](list)
}

// Canaries go out through DIRECT so they measure the link itself, and through an
// outbound rather than a raw dial so the socket is still protected from the tun.
// A whitelist accepts the TCP handshake on any address and cuts the data, so a
// foreign canary is judged by the TLS handshake, which a gate cannot forge.
func (rcxCoreRuntime) Reach(ctx context.Context, address string, domestic bool) rcxProbeOutcome {
	direct := lookupProxy("DIRECT")
	if direct == nil {
		return rcxProbeOverloaded
	}
	target, err := netip.ParseAddrPort(address)
	if err != nil {
		return rcxProbeOverloaded
	}
	metadata := &constant.Metadata{
		NetWork: constant.TCP,
		Type:    constant.INNER,
		DstIP:   target.Addr(),
		DstPort: target.Port(),
	}
	conn, err := direct.DialContext(ctx, metadata)
	if err != nil {
		if ctx.Err() != nil {
			return rcxProbeOverloaded
		}
		return rcxProbeFail
	}
	if domestic {
		_ = conn.Close()
		return rcxProbeOK
	}
	defer conn.Close()
	return rcxVerifyTLS(ctx, conn, address)
}

// The host's delay test over the whole park, run on the engine's own schedule
// rather than the health-check cadence. The window gates queueing only: a
// cancelled URLTest is recorded as dead by the adapter, so a dial already in
// flight must be left to answer honestly instead of being stamped as a timeout
// the engine would then believe.
func (rcxCoreRuntime) Sweep(ctx context.Context, nodes []string) {
	url := currentTestURL()
	var probes sync.WaitGroup
	for _, name := range nodes {
		proxy, ok := lookupProxy(name).(*adapter.Proxy)
		if !ok {
			continue
		}
		probes.Add(1)
		node := proxy
		safeGoDetached("rcx host probe", func() {
			defer probes.Done()
			if !acquireDelayTestSlot(ctx) {
				return
			}
			defer releaseDelayTestSlot()
			probeCtx, cancel := context.WithTimeout(ctx, rcxHostProbeDial)
			defer cancel()
			_, _ = node.URLTest(probeCtx, url, anyDelayTestStatus)
		})
	}
	done := make(chan struct{})
	safeGoDetached("rcx host sweep wait", func() {
		probes.Wait()
		close(done)
	})
	select {
	case <-done:
	case <-ctx.Done():
	}
}

// Only the foreign canaries verify: their hosts carry public-root IP-SAN
// certificates, which the domestic ones do not.
func rcxVerifyTLS(ctx context.Context, conn net.Conn, address string) rcxProbeOutcome {
	tlsConfig, err := ca.GetTLSConfig(ca.Option{})
	if err != nil {
		return rcxProbeOverloaded
	}
	tlsConfig.ServerName = rcxHostOf(address)
	tlsConn := mihomoTLS.Client(conn, tlsConfig)
	if err := tlsConn.HandshakeContext(ctx); err != nil {
		if ctx.Err() != nil {
			return rcxProbeOverloaded
		}
		return rcxProbeStatusMismatch
	}
	req, err := http.NewRequest(http.MethodHead, "https://"+address+"/", nil)
	if err != nil {
		return rcxProbeOverloaded
	}
	req = req.WithContext(ctx)
	client := http.Client{
		Transport: &http.Transport{
			DialTLSContext: func(context.Context, string, string) (net.Conn, error) {
				return tlsConn, nil
			},
			DisableKeepAlives: true,
		},
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}
	defer client.CloseIdleConnections()
	resp, err := client.Do(req)
	if err != nil {
		if ctx.Err() != nil {
			return rcxProbeOverloaded
		}
		return rcxProbeStatusMismatch
	}
	_ = resp.Body.Close()
	return rcxProbeOK
}

func (rcxCoreRuntime) Connections() []rcxConnSample {
	samples := make([]rcxConnSample, 0, 64)
	statistic.DefaultManager.Range(func(tracker statistic.Tracker) bool {
		info := tracker.Info()
		if info == nil {
			return true
		}
		node := info.Chain.Last()
		if node == "" {
			return true
		}
		sample := rcxConnSample{
			Key:   tracker.ID(),
			Node:  node,
			Up:    info.UploadTotal.Load(),
			Down:  info.DownloadTotal.Load(),
			Start: info.Start,
		}
		if info.Metadata != nil {
			sample.Host = info.Metadata.Host
		}
		samples = append(samples, sample)
		return true
	})
	return samples
}

func (rcxCoreRuntime) CloseConnections(ids []string) {
	if len(ids) == 0 {
		return
	}
	wanted := make(map[string]struct{}, len(ids))
	for _, id := range ids {
		wanted[id] = struct{}{}
	}
	statistic.DefaultManager.Range(func(tracker statistic.Tracker) bool {
		if _, ok := wanted[tracker.ID()]; ok {
			_ = tracker.Close()
		}
		return true
	})
}

func (rcxCoreRuntime) Publish(status rcxStatus) {
	sendMessage(Message{Type: RcxStatusMessage, Data: status})
}

func (rcxCoreRuntime) Now() time.Time {
	return time.Now()
}
