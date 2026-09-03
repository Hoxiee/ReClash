package main

import (
	"context"
	"net"
	"net/netip"
	"strconv"
	"strings"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

const (
	rcxGroupPrefix   = "RCX-"
	rcxGroupNode     = "RCX-NODE"
	rcxGroupFinal    = "RCX-FINAL"
	rcxGroupDirect   = "RCX-DIRECT"
	rcxGroupDomestic = "RCX-DOMESTIC"
)

type rcxCoreRuntime struct{}

type rcxNodeLister interface {
	Proxies() []constant.Proxy
}

type rcxNodeReporter interface {
	Now() string
}

func rcxNodeGroupAdapter() (*adapter.Proxy, bool) {
	group := lookupProxy(rcxGroupNode)
	if group == nil {
		return nil, false
	}
	proxy, ok := group.(*adapter.Proxy)
	return proxy, ok
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
	members := make([]rcxMember, 0, len(nodes))
	for _, node := range nodes {
		if !rcxRoutableNode(node) {
			continue
		}
		members = append(members, rcxMember{
			Name:        node.Name(),
			Type:        node.Type().String(),
			Port:        rcxPortOf(node.Addr()),
			SupportsUDP: node.SupportUDP(),
			Order:       uint16(len(members)),
		})
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
	selectMu.Lock()
	defer selectMu.Unlock()

	proxy, ok := rcxNodeGroupAdapter()
	if !ok {
		return errGroupNotFound
	}
	selector, ok := proxy.ProxyAdapter.(outboundgroup.SelectAble)
	if !ok {
		return errGroupNotSelect
	}
	return selector.Set(node)
}

func (rcxCoreRuntime) Mode() string {
	return tunnel.Mode().String()
}

// mmdb.IPInstance() calls log.Fatalln behind a sync.Once when the file is
// missing or truncated, which would take the whole foreground service down.
func (rcxCoreRuntime) Country(node string) string {
	proxy := lookupProxy(node)
	if proxy == nil {
		return ""
	}
	address, err := netip.ParseAddr(rcxHostOf(proxy.Addr()))
	if err != nil {
		return ""
	}
	if !mmdb.Verify(constant.Path.MMDB()) {
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

func (rcxCoreRuntime) Traffic() map[string]rcxTrafficSample {
	samples := map[string]rcxTrafficSample{}
	statistic.DefaultManager.Range(func(tracker statistic.Tracker) bool {
		info := tracker.Info()
		if info == nil {
			return true
		}
		node := info.Chain.Last()
		if node == "" {
			return true
		}
		sample := samples[node]
		sample.Up += info.UploadTotal.Load()
		sample.Down += info.DownloadTotal.Load()
		samples[node] = sample
		return true
	})
	return samples
}

func (rcxCoreRuntime) Publish(status rcxStatus) {
	sendMessage(Message{Type: RcxStatusMessage, Data: status})
}

func (rcxCoreRuntime) Now() time.Time {
	return time.Now()
}
