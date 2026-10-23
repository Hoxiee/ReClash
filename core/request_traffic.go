package core

import (
	"sync"
	"sync/atomic"
	"time"

	"github.com/metacubex/mihomo/tunnel/statistic"
)

// mihomo announces a connection only as it opens, and has no hook for its
// close; the request list learns the traffic that follows from these reports.
const requestTrafficInterval = time.Second

// A full bulk queue drops a report; a closed request holds its connection only this many retries.
const requestTrafficCloseRetries = 5

type RequestTraffic struct {
	Id       string `json:"id"`
	Upload   int64  `json:"upload"`
	Download int64  `json:"download"`
}

type watchedRequest struct {
	tracker  statistic.Tracker
	upload   int64
	download int64
	// The tracker is announced before the manager stores it, so a request
	// missing from the manager on its first report may still be opening.
	fresh         bool
	closedReports int
}

type requestTrafficWatch struct {
	mu       sync.Mutex
	requests map[string]*watchedRequest
	running  bool
}

var currentRequestTraffic = requestTrafficWatch{
	requests: map[string]*watchedRequest{},
}

// rcxHints pauses watching while the host is hidden; its request list retains the last totals.
var (
	hostForeground    atomic.Bool
	hostForegroundMu  sync.Mutex
	hostForegroundSeq uint64
)

func init() {
	hostForeground.Store(true)
}

func (w *requestTrafficWatch) add(tracker statistic.Tracker) (start bool) {
	info := tracker.Info()
	return w.insert(tracker, info.UploadTotal.Load(), info.DownloadTotal.Load())
}

// The host may have missed these totals, so the first report carries them.
func (w *requestTrafficWatch) resume(tracker statistic.Tracker) (start bool) {
	return w.insert(tracker, -1, -1)
}

func (w *requestTrafficWatch) insert(tracker statistic.Tracker, upload, download int64) (start bool) {
	w.mu.Lock()
	defer w.mu.Unlock()
	if _, watched := w.requests[tracker.ID()]; !watched {
		w.requests[tracker.ID()] = &watchedRequest{
			tracker:  tracker,
			upload:   upload,
			download: download,
			fresh:    true,
		}
	}
	start = !w.running
	w.running = true
	return start
}

func (w *requestTrafficWatch) collect(
	isOpen func(id string) bool,
	queue func([]RequestTraffic) (queued bool),
) (watching bool) {
	w.mu.Lock()
	defer w.mu.Unlock()
	var changed []RequestTraffic
	for id, request := range w.requests {
		if request.closedReports > 0 || !request.fresh && !isOpen(id) {
			request.closedReports++
		}
		request.fresh = false
		info := request.tracker.Info()
		upload, download := info.UploadTotal.Load(), info.DownloadTotal.Load()
		if upload != request.upload || download != request.download {
			changed = append(changed, RequestTraffic{Id: id, Upload: upload, Download: download})
		}
	}
	queued := len(changed) == 0 || queue(changed)
	if queued {
		for _, traffic := range changed {
			request := w.requests[traffic.Id]
			request.upload, request.download = traffic.Upload, traffic.Download
		}
	}
	for id, request := range w.requests {
		if request.closedReports > 0 && (queued || request.closedReports > requestTrafficCloseRetries) {
			delete(w.requests, id)
		}
	}
	w.running = len(w.requests) > 0
	return w.running
}

// Recheck under the lock so a stale condition cannot clear a newly added request.
func (w *requestTrafficWatch) clearUnless(keep func() bool) (cleared bool) {
	w.mu.Lock()
	defer w.mu.Unlock()
	if keep() {
		return false
	}
	clear(w.requests)
	w.running = false
	return true
}

func watchRequestTraffic(tracker statistic.Tracker) {
	if hostForeground.Load() && currentRequestTraffic.add(tracker) {
		safeGo("requestTrafficWatch", runRequestTrafficWatch)
	}
}

func setHostForeground(foreground bool, seq uint64) {
	hostForegroundMu.Lock()
	defer hostForegroundMu.Unlock()
	if seq < hostForegroundSeq {
		return
	}
	hostForegroundSeq = seq
	if hostForeground.Swap(foreground) == foreground || !foreground || !hasEventListener() {
		return
	}
	start := false
	statistic.DefaultManager.Range(func(tracker statistic.Tracker) bool {
		start = currentRequestTraffic.resume(tracker) || start
		return true
	})
	if start {
		safeGo("requestTrafficWatch", runRequestTrafficWatch)
	}
}

func requestTrafficWanted() bool {
	return hasEventListener() && hostForeground.Load()
}

func runRequestTrafficWatch() {
	ticker := time.NewTicker(requestTrafficInterval)
	defer ticker.Stop()
	for range ticker.C {
		if currentRequestTraffic.clearUnless(requestTrafficWanted) {
			return
		}
		watching := currentRequestTraffic.collect(
			func(id string) bool {
				return statistic.DefaultManager.Get(id) != nil
			},
			func(changed []RequestTraffic) bool {
				return sendMessage(RequestTrafficMessage, changed)
			},
		)
		if !watching {
			return
		}
	}
}
