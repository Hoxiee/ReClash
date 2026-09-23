package subscription

import (
	"context"
	"errors"
	"io"
	"net"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
)

const subscriptionBodyLimit = 16 * 1024 * 1024

var errSubscriptionProtection = errors.New("protected subscription transport unavailable")
var errSubscriptionTooLarge = errors.New("subscription response is too large")

type FetchParams struct {
	URL           string            `json:"url"`
	Headers       map[string]string `json:"headers"`
	TimeoutMillis int               `json:"timeoutMillis"`
}

type FetchResult struct {
	Status  int                 `json:"status"`
	Headers map[string][]string `json:"headers"`
	Body    []byte              `json:"body"`
}

var subscriptionFetches = struct {
	sync.Mutex
	next   uint64
	cancel map[uint64]context.CancelFunc
}{cancel: make(map[uint64]context.CancelFunc)}

func cancelSubscriptionFetches() {
	subscriptionFetches.Lock()
	defer subscriptionFetches.Unlock()
	for _, cancel := range subscriptionFetches.cancel {
		cancel()
	}
}

func subscriptionContext(timeout time.Duration) (context.Context, func()) {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	subscriptionFetches.Lock()
	subscriptionFetches.next++
	id := subscriptionFetches.next
	subscriptionFetches.cancel[id] = cancel
	subscriptionFetches.Unlock()
	return ctx, func() {
		cancel()
		subscriptionFetches.Lock()
		delete(subscriptionFetches.cancel, id)
		subscriptionFetches.Unlock()
	}
}

type subscriptionDialer struct {
	mu      sync.Mutex
	refused bool
	control func(string, string, syscall.RawConn) error
	servers []string
}

func newSubscriptionDialer(control func(string, string, syscall.RawConn) error, servers []string) *subscriptionDialer {
	return &subscriptionDialer{control: control, servers: servers}
}

func (d *subscriptionDialer) DialContext(ctx context.Context, network, address string) (net.Conn, error) {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	guard := func(network, address string, connection syscall.RawConn) error {
		d.mu.Lock()
		defer d.mu.Unlock()
		if d.refused {
			cancel()
			return errSubscriptionProtection
		}
		if err := d.control(network, address, connection); err != nil {
			d.refused = true
			cancel()
			return errors.Join(errSubscriptionProtection, err)
		}
		return nil
	}
	dialer := &net.Dialer{Control: guard, Timeout: 12 * time.Second}
	var next atomic.Uint64
	dialer.Resolver = &net.Resolver{
		PreferGo: true,
		Dial: func(ctx context.Context, network, _ string) (net.Conn, error) {
			if len(d.servers) == 0 {
				return nil, errSubscriptionProtection
			}
			server := d.servers[(next.Add(1)-1)%uint64(len(d.servers))]
			dnsDialer := net.Dialer{Control: guard, Timeout: 4 * time.Second}
			return dnsDialer.DialContext(ctx, network, server)
		},
	}
	connection, err := dialer.DialContext(ctx, network, address)
	d.mu.Lock()
	defer d.mu.Unlock()
	if d.refused {
		if connection != nil {
			_ = connection.Close()
		}
		return nil, errSubscriptionProtection
	}
	return connection, err
}

type subscriptionConnector interface {
	DialContext(context.Context, string, string) (net.Conn, error)
}

func fetchSubscription(params *FetchParams, dialer subscriptionConnector) (*FetchResult, error) {
	parsed, err := url.Parse(params.URL)
	if err != nil || (parsed.Scheme != "http" && parsed.Scheme != "https") || parsed.Hostname() == "" || parsed.User != nil || len(params.URL) > 8192 {
		return nil, errors.New("invalid subscription URL")
	}
	if params.TimeoutMillis <= 0 || params.TimeoutMillis > 30000 || len(params.Headers) > 64 {
		return nil, errors.New("invalid subscription request limits")
	}
	ctx, cancel := subscriptionContext(time.Duration(params.TimeoutMillis) * time.Millisecond)
	defer cancel()
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, params.URL, nil)
	if err != nil {
		return nil, errors.New("invalid subscription request")
	}
	headerBytes := 0
	for name, value := range params.Headers {
		headerBytes += len(name) + len(value)
		if headerBytes > 65536 {
			return nil, errors.New("subscription headers are too large")
		}
		switch strings.ToLower(name) {
		case "host", "proxy-authorization", "proxy-connection", "connection", "transfer-encoding", "content-length":
			return nil, errors.New("unsupported subscription header")
		}
		request.Header.Set(name, value)
	}
	transport := &http.Transport{
		DialContext:            dialer.DialContext,
		TLSHandshakeTimeout:    12 * time.Second,
		ResponseHeaderTimeout:  12 * time.Second,
		MaxResponseHeaderBytes: 64 * 1024,
		DisableKeepAlives:      true,
	}
	defer transport.CloseIdleConnections()
	client := &http.Client{
		Transport:     transport,
		CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse },
	}
	response, err := client.Do(request)
	if err != nil {
		return nil, err
	}
	defer response.Body.Close()
	result := &FetchResult{Status: response.StatusCode, Headers: response.Header, Body: []byte{}}
	if response.StatusCode < 200 || response.StatusCode >= 300 {
		return result, nil
	}
	if response.ContentLength > subscriptionBodyLimit {
		return nil, errSubscriptionTooLarge
	}
	result.Body, err = io.ReadAll(io.LimitReader(response.Body, subscriptionBodyLimit+1))
	if err != nil {
		return nil, err
	}
	if len(result.Body) > subscriptionBodyLimit {
		return nil, errSubscriptionTooLarge
	}
	return result, nil
}
