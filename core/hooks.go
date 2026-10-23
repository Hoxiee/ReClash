package core

import (
	"context"
	"errors"
	"sync"
	"time"

	"github.com/metacubex/mihomo/adapter"
	mihomoHttp "github.com/metacubex/mihomo/component/http"
	"github.com/metacubex/mihomo/component/proxydialer"
	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

func init() {
	mihomoHttp.TLSConfigHook = relaxCertVerify
	adapter.UrlTestHook = func(url string, name string, delay uint16, timedOut bool) {
		sendMessage(DelayMessage, &Delay{Url: url, Name: name, Value: delayValue(delay, timedOut)})
		if e := rcxIfReady(); e != nil && url == currentTestURL() && !rcxOwnProbes.owns(name) {
			e.NoteURLTest(name, int(delay))
		}
	}
	adapter.DialResultHook = func(name string, _ string, err error, _ time.Duration) {
		if err == nil || errors.Is(err, context.Canceled) {
			return
		}
		if e := rcxIfReady(); e != nil {
			e.NoteDial(name, true)
		}
	}
	// The whole chain is credited: an opaque nested group is a member under
	// its own name, the leaf under it is not.
	statistic.DefaultFirstProgressNotify = func(c statistic.Tracker) {
		if e := rcxIfReady(); e != nil {
			for _, name := range c.Info().Chain {
				e.NoteTraffic(name)
			}
		}
	}
	statistic.DefaultRequestNotify = func(c statistic.Tracker) {
		notifyProbeRoute(c)
		if hasEventListener() {
			sendMessage(RequestMessage, c)
			watchRequestTraffic(c)
		}
	}
	dns.DefaultQueryNotify = func(record dns.QueryRecord) {
		if hasEventListener() {
			sendMessage(DnsMessage, newDnsQuery(record))
		}
	}
	executor.DefaultProviderLoadedHook = func(providerName string) {
		requestRcxTopologyRefresh()
		scheduleReclaimOwnership()
		scheduleLoadMemoryRelease()
		sendMessage(LoadedMessage, providerName)
	}
	updater.GeoUpdateHook = onGeoUpdate
	tunnel.DirectSplitHook = rcxDirectSplit
	proxydialer.DefaultLoopNotify = reportDialerLoop
}

// Every dial through a looping dialer fails; one report stands for the burst.
const dialerLoopReportInterval = 3 * time.Second

var dialerLoopReports sync.Map

func reportDialerLoop(proxyName string) {
	now := time.Now()
	if last, ok := dialerLoopReports.Load(proxyName); ok && now.Sub(last.(time.Time)) < dialerLoopReportInterval {
		return
	}
	dialerLoopReports.Store(proxyName, now)
	sendMessage(DialerLoopMessage, proxyName)
}
