package core

import (
	"io"
	"net"
	"testing"

	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

type pipeTracker interface {
	statistic.Tracker
	io.Writer
}

func newPipeTracker(t *testing.T) pipeTracker {
	t.Helper()
	local, remote := net.Pipe()
	go func() { _, _ = io.Copy(io.Discard, remote) }()
	direct := outbound.NewDirectWithOption(outbound.DirectOption{Name: "DIRECT"})
	tracker := statistic.NewTCPTracker(
		outbound.NewConn(local, direct),
		statistic.DefaultManager,
		&constant.Metadata{},
		nil,
		0,
		0,
		false,
	)
	t.Cleanup(func() {
		_ = tracker.Close()
		_ = remote.Close()
	})
	return tracker
}

func collectDelivered(watch *requestTrafficWatch, isOpen func(string) bool) (changed []RequestTraffic, watching bool) {
	watching = watch.collect(isOpen, func(traffic []RequestTraffic) bool {
		changed = traffic
		return true
	})
	return changed, watching
}

func TestRequestTrafficReportsChangesUntilTheRequestCloses(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	open := true
	isOpen := func(string) bool { return open }

	if !watch.add(tracker) {
		t.Fatal("the first request did not start the watch")
	}
	if changed, watching := collectDelivered(&watch, isOpen); len(changed) != 0 || !watching {
		t.Fatalf("idle request: changed %v, watching %v", changed, watching)
	}

	if _, err := tracker.Write([]byte("hello")); err != nil {
		t.Fatalf("write: %v", err)
	}
	changed, _ := collectDelivered(&watch, isOpen)
	if len(changed) != 1 || changed[0].Id != tracker.ID() || changed[0].Upload != 5 {
		t.Fatalf("after a write: %v", changed)
	}
	if changed, _ := collectDelivered(&watch, isOpen); len(changed) != 0 {
		t.Fatalf("unchanged traffic reported again: %v", changed)
	}

	if _, err := tracker.Write([]byte("bye")); err != nil {
		t.Fatalf("write: %v", err)
	}
	open = false
	changed, watching := collectDelivered(&watch, isOpen)
	if len(changed) != 1 || changed[0].Upload != 8 || watching {
		t.Fatalf("closed request: changed %v, watching %v", changed, watching)
	}
	if !watch.add(tracker) {
		t.Fatal("a request after the watch stopped did not restart it")
	}
}

func TestRequestTrafficKeepsARequestTheManagerHasNotStoredYet(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	closed := func(string) bool { return false }

	watch.add(tracker)
	if _, watching := collectDelivered(&watch, closed); !watching {
		t.Fatal("a request announced before it was stored was dropped on its first report")
	}
	if _, watching := collectDelivered(&watch, closed); watching {
		t.Fatal("a closed request was kept past its second report")
	}
}

func TestRequestTrafficResendsTheLastTotalsOfAClosedRequestUntilQueued(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	open := true
	isOpen := func(string) bool { return open }
	dropped := func([]RequestTraffic) bool { return false }

	watch.add(tracker)
	collectDelivered(&watch, isOpen)
	if _, err := tracker.Write([]byte("bye")); err != nil {
		t.Fatalf("write: %v", err)
	}
	open = false
	if !watch.collect(isOpen, dropped) {
		t.Fatal("a closed request whose last totals were dropped was let go")
	}
	changed, watching := collectDelivered(&watch, isOpen)
	if len(changed) != 1 || changed[0].Upload != 3 || watching {
		t.Fatalf("after the dropped report: changed %v, watching %v", changed, watching)
	}
}

func TestRequestTrafficGivesUpOnAClosedRequestItCannotReport(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	closed := func(string) bool { return false }
	dropped := func([]RequestTraffic) bool { return false }

	watch.add(tracker)
	watch.collect(closed, dropped)
	if _, err := tracker.Write([]byte("bye")); err != nil {
		t.Fatalf("write: %v", err)
	}
	for report := 1; report <= requestTrafficCloseRetries; report++ {
		if !watch.collect(closed, dropped) {
			t.Fatalf("let go after %d dropped reports", report)
		}
	}
	if watch.collect(closed, dropped) {
		t.Fatal("a closed request outlived its retries")
	}
}

func TestRequestTrafficResumeReportsTotalsTheHostMissed(t *testing.T) {
	tracker := newPipeTracker(t)
	if _, err := tracker.Write([]byte("hidden")); err != nil {
		t.Fatalf("write: %v", err)
	}
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	open := func(string) bool { return true }

	if !watch.resume(tracker) {
		t.Fatal("resuming an idle watch did not start it")
	}
	changed, _ := collectDelivered(&watch, open)
	if len(changed) != 1 || changed[0].Upload != 6 {
		t.Fatalf("first report after resume: %v", changed)
	}
	if changed, _ := collectDelivered(&watch, open); len(changed) != 0 {
		t.Fatalf("unchanged totals reported again: %v", changed)
	}
}

func TestRequestTrafficResumeKeepsAWatchedRequest(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	open := func(string) bool { return true }

	watch.add(tracker)
	collectDelivered(&watch, open)
	if watch.resume(tracker) {
		t.Fatal("resume restarted a running watch")
	}
	if changed, _ := collectDelivered(&watch, open); len(changed) != 0 {
		t.Fatalf("resume reset the totals of a watched request: %v", changed)
	}
}

func TestRequestTrafficClearsOnlyWhenNotWanted(t *testing.T) {
	tracker := newPipeTracker(t)
	watch := requestTrafficWatch{requests: map[string]*watchedRequest{}}
	watch.add(tracker)

	if watch.clearUnless(func() bool { return true }) || len(watch.requests) != 1 {
		t.Fatal("a wanted watch was cleared")
	}
	if !watch.clearUnless(func() bool { return false }) || len(watch.requests) != 0 || watch.running {
		t.Fatal("an unwanted watch kept its requests")
	}
	if !watch.add(tracker) {
		t.Fatal("a request after the clear did not restart the watch")
	}
}

func TestHiddenHostWatchesNoRequestTraffic(t *testing.T) {
	hostForegroundMu.Lock()
	seq := hostForegroundSeq
	hostForegroundMu.Unlock()
	t.Cleanup(func() { hostForeground.Store(true) })

	setHostForeground(false, seq+2)
	setHostForeground(true, seq+1)
	if hostForeground.Load() {
		t.Fatal("an older visibility hint overrode a newer one")
	}
	tracker := newPipeTracker(t)
	watchRequestTraffic(tracker)
	currentRequestTraffic.mu.Lock()
	_, watched := currentRequestTraffic.requests[tracker.ID()]
	currentRequestTraffic.mu.Unlock()
	if watched {
		t.Fatal("a hidden host watched a new request")
	}
}
