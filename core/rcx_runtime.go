package main

import (
	"context"
	"crypto/sha1"
	"encoding/hex"
	"net"
	"net/netip"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

const (
	rcxResolveTimeout = 3 * time.Second
	rcxResolveRetry   = 10 * time.Minute
	rcxMmdbRecheck    = time.Minute
)

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
	url := currentTestURL()
	members := make([]rcxMember, 0, len(nodes))
	for _, node := range nodes {
		if !rcxRoutableNode(node) {
			continue
		}
		hostMs, hostDead := rcxHostDelay(node, url)
		members = append(members, rcxMember{
			Name:        node.Name(),
			ID:          rcxNodeKey(node.Type().String(), node.Addr(), ""),
			Type:        node.Type().String(),
			Port:        rcxPortOf(node.Addr()),
			SupportsUDP: node.SupportUDP(),
			HostMs:      hostMs,
			HostDead:    hostDead,
			Order:       uint16(len(members)),
		})
	}
	return rcxSeparateCollisions(members)
}

// The delay test the user runs by hand already covers the whole park, which no
// probe budget can. A missing entry is silence, not a verdict: mihomo folds
// every test URL into one global alive flag, so only a record here condemns.
func rcxHostDelay(node constant.Proxy, url string) (int, bool) {
	if !node.AliveForTestUrl(url) {
		if _, recorded := node.ExtraDelayHistories()[url]; !recorded {
			return 0, false
		}
		return 0, true
	}
	return rcxHostDelayValue(node.LastDelayForTestUrl(url))
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
func (rcxCoreRuntime) Reach(ctx context.Context, address string) rcxProbeOutcome {
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
	dialCtx, cancel := context.WithTimeout(ctx, rcxCanaryTimeout)
	defer cancel()
	conn, err := direct.DialContext(dialCtx, metadata)
	if err != nil {
		if ctx.Err() != nil {
			return rcxProbeOverloaded
		}
		return rcxProbeFail
	}
	_ = conn.Close()
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

func (rcxCoreRuntime) CloseConnections(node string) {
	statistic.DefaultManager.Range(func(tracker statistic.Tracker) bool {
		info := tracker.Info()
		if info != nil && info.Chain.Last() == node {
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
