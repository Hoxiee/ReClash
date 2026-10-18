package core

import (
	"context"
	"encoding/base64"
	"errors"
	"io"
	"net"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

const (
	subscriptionFetchMaxConcurrent = 8
	subscriptionFetchMaxRedirects  = 5
	subscriptionFetchWireLimit     = 16 << 20
	subscriptionFetchBodyLimit     = subscriptionFetchWireLimit
	subscriptionFetchHeaderLimit   = 64 << 10
	subscriptionFetchFieldLimit    = 8 << 10
	subscriptionFetchTimeoutLimit  = 2 * time.Minute
)

var (
	errSubscriptionTooLarge             = errors.New("subscription response exceeds size limit")
	errSubscriptionCancelled            = errors.New("subscription fetch cancelled")
	errSubscriptionProtectedUnavailable = errors.New("protected transport unavailable")
	errSubscriptionProtectedRefused     = errors.New("socket protection refused")
)

type SubscriptionFetchParams struct {
	RequestID     string            `json:"requestId"`
	URL           string            `json:"url"`
	Headers       map[string]string `json:"headers"`
	TimeoutMillis int               `json:"timeoutMillis"`
	MaxBytes      int64             `json:"maxBytes"`
	Protected     bool              `json:"protected"`
}

type CancelSubscriptionFetchParams struct {
	RequestID string `json:"requestId"`
}

type SubscriptionFetchResult struct {
	Status     int                 `json:"status"`
	Headers    map[string][]string `json:"headers"`
	BodyBase64 string              `json:"bodyBase64"`
	FinalURL   string              `json:"finalUrl"`
	Protected  bool                `json:"protected"`
}

type subscriptionConnector interface {
	DialContext(context.Context, string, string) (net.Conn, error)
}

// Android installs the only protected connector; other builds fail closed.
var protectedSubscriptionConnector func() (subscriptionConnector, error)

var subscriptionFetches = struct {
	sync.Mutex
	active map[string]context.CancelFunc
}{active: make(map[string]context.CancelFunc)}

func registerSubscriptionFetch(id string, timeout time.Duration) (context.Context, func(), error) {
	if id == "" || len(id) > 128 {
		return nil, nil, errors.New("invalid request id")
	}
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	subscriptionFetches.Lock()
	if _, exists := subscriptionFetches.active[id]; exists || len(subscriptionFetches.active) >= subscriptionFetchMaxConcurrent {
		subscriptionFetches.Unlock()
		cancel()
		return nil, nil, errors.New("subscription fetch unavailable")
	}
	subscriptionFetches.active[id] = cancel
	subscriptionFetches.Unlock()
	return ctx, func() {
		cancel()
		subscriptionFetches.Lock()
		delete(subscriptionFetches.active, id)
		subscriptionFetches.Unlock()
	}, nil
}

func cancelSubscriptionFetch(id string) bool {
	subscriptionFetches.Lock()
	cancel, ok := subscriptionFetches.active[id]
	subscriptionFetches.Unlock()
	if ok {
		cancel()
	}
	return ok
}

func cancelSubscriptionFetches() {
	subscriptionFetches.Lock()
	cancels := make([]context.CancelFunc, 0, len(subscriptionFetches.active))
	for _, cancel := range subscriptionFetches.active {
		cancels = append(cancels, cancel)
	}
	subscriptionFetches.Unlock()
	for _, cancel := range cancels {
		cancel()
	}
}

func handleFetchSubscription(params SubscriptionFetchParams) (*SubscriptionFetchResult, error) {
	if !params.Protected {
		return nil, &MethodError{
			Code:    "invalid_arguments",
			Message: "Core subscription fetch requires protected transport",
		}
	}
	if protectedSubscriptionConnector == nil {
		return nil, subscriptionFetchMethodError(errSubscriptionProtectedUnavailable)
	}
	connector, err := protectedSubscriptionConnector()
	if err != nil {
		return nil, subscriptionFetchMethodError(err)
	}
	result, err := fetchSubscription(params, connector)
	if err != nil {
		return nil, subscriptionFetchMethodError(err)
	}
	result.Protected = true
	return result, nil
}

func fetchSubscription(params SubscriptionFetchParams, connector subscriptionConnector) (*SubscriptionFetchResult, error) {
	if params.Headers != nil {
		headersCopy := make(map[string]string, len(params.Headers))
		for key, value := range params.Headers {
			headersCopy[key] = value
		}
		params.Headers = headersCopy
	}
	target, err := parseSubscriptionURL(params.URL)
	if err != nil {
		return nil, err
	}
	if params.TimeoutMillis <= 0 || params.TimeoutMillis > int(subscriptionFetchTimeoutLimit/time.Millisecond) {
		return nil, errors.New("invalid subscription timeout")
	}
	if params.MaxBytes <= 0 || params.MaxBytes > subscriptionFetchWireLimit {
		return nil, errors.New("invalid subscription byte limit")
	}
	if err := validateSubscriptionHeaders(params.Headers); err != nil {
		return nil, err
	}
	ctx, unregister, err := registerSubscriptionFetch(params.RequestID, time.Duration(params.TimeoutMillis)*time.Millisecond)
	if err != nil {
		return nil, err
	}
	defer unregister()
	headers := make(http.Header, len(params.Headers)+1)
	for k, v := range params.Headers {
		headers.Set(k, v)
	}
	if target.User != nil {
		password, _ := target.User.Password()
		headers.Set("Authorization", "Basic "+base64.StdEncoding.EncodeToString([]byte(target.User.Username()+":"+password)))
		target.User = nil
	}
	wire := &atomic.Int64{}
	for redirects := 0; ; redirects++ {
		result, location, err := fetchSubscriptionHop(ctx, connector, target, headers, params.MaxBytes, wire)
		if err != nil {
			if ctx.Err() == context.Canceled {
				return nil, errSubscriptionCancelled
			}
			return nil, err
		}
		if location == "" {
			result.Protected = params.Protected
			return result, nil
		}
		if redirects >= subscriptionFetchMaxRedirects {
			return nil, errors.New("too many subscription redirects")
		}
		next, err := target.Parse(location)
		if err == nil && next != nil {
			next.Scheme = strings.ToLower(next.Scheme)
		}
		if err != nil || validateSubscriptionRedirect(target, next) != nil {
			return nil, errors.New("invalid redirect")
		}
		if !sameSubscriptionOrigin(target, next) {
			headers = retainedSubscriptionHeaders(headers)
		}
		target = next
	}
}

func parseSubscriptionURL(raw string) (*url.URL, error) {
	if len(raw) == 0 || len(raw) > subscriptionFetchFieldLimit {
		return nil, errors.New("invalid subscription URL")
	}
	u, err := url.Parse(raw)
	if err != nil || validateSubscriptionURL(u) != nil {
		return nil, errors.New("invalid subscription URL")
	}
	u.Scheme = strings.ToLower(u.Scheme)
	return u, nil
}

func validateSubscriptionRedirect(current, next *url.URL) error {
	if next == nil || next.User != nil || validateSubscriptionURL(next) != nil {
		return errors.New("invalid redirect")
	}
	if strings.EqualFold(current.Scheme, "https") && !strings.EqualFold(next.Scheme, "https") {
		return errors.New("HTTPS downgrade refused")
	}
	return nil
}

func validateSubscriptionURL(u *url.URL) error {
	if u == nil || u.Opaque != "" || u.Hostname() == "" || !(strings.EqualFold(u.Scheme, "http") || strings.EqualFold(u.Scheme, "https")) {
		return errors.New("invalid subscription URL")
	}
	if port := u.Port(); port != "" {
		for _, digit := range port {
			if digit < '0' || digit > '9' {
				return errors.New("invalid subscription URL port")
			}
		}
		value, err := strconv.Atoi(port)
		if err != nil || value < 1 || value > 65535 {
			return errors.New("invalid subscription URL port")
		}
	}
	return nil
}

func validateSubscriptionHeaders(headers map[string]string) error {
	if len(headers) > 64 {
		return errors.New("invalid request headers")
	}
	total := 0
	seen := make(map[string]struct{}, len(headers))
	for name, value := range headers {
		lowerName := strings.ToLower(name)
		if _, exists := seen[lowerName]; exists {
			return errors.New("invalid request headers")
		}
		seen[lowerName] = struct{}{}
		total += len(name) + len(value) + 4
		if name == "" || len(name) > subscriptionFetchFieldLimit || len(value) > subscriptionFetchFieldLimit || total > subscriptionFetchHeaderLimit || !validSubscriptionHeaderName(name) || hasHeaderControl(name) || hasHeaderControl(value) || strings.HasPrefix(lowerName, "reclash-") {
			return errors.New("invalid request headers")
		}
		switch lowerName {
		case "host", "connection", "proxy-connection", "proxy-authorization", "transfer-encoding", "content-length", "upgrade", "te", "trailer", "keep-alive", "expect", "content-encoding", "content-range", "set-cookie", "accept-ranges", "age", "allow", "etag", "expires", "last-modified", "location", "retry-after", "server", "vary", "www-authenticate", "proxy-authenticate", "subscription-userinfo", "content-disposition", "x-hwid-max-devices-reached", "x-hwid-not-supported":
			return errors.New("unsupported request header")
		}
	}
	return nil
}

func validateResourceHeaders(headers map[string]string) error {
	if err := validateSubscriptionHeaders(headers); err != nil {
		return err
	}
	for name := range headers {
		switch strings.ToLower(name) {
		case "x-hwid", "x-device-os", "x-ver-os", "x-device-model", "x-device-locale":
			return errors.New("device identity cannot be sent to resource providers")
		}
	}
	return nil
}

func hasHeaderControl(s string) bool {
	for _, r := range s {
		if r < 0x20 || r == 0x7f {
			return true
		}
	}
	return false
}
func validSubscriptionHeaderName(s string) bool {
	for _, r := range s {
		if !(r >= 'a' && r <= 'z' || r >= 'A' && r <= 'Z' || r >= '0' && r <= '9' || strings.ContainsRune("!#$%&'*+-.^_`|~", r)) {
			return false
		}
	}
	return true
}
func effectiveSubscriptionPort(u *url.URL) string {
	if u.Port() != "" {
		return u.Port()
	}
	if strings.EqualFold(u.Scheme, "https") {
		return "443"
	}
	return "80"
}
func sameSubscriptionOrigin(a, b *url.URL) bool {
	return strings.EqualFold(a.Scheme, b.Scheme) && strings.EqualFold(a.Hostname(), b.Hostname()) && effectiveSubscriptionPort(a) == effectiveSubscriptionPort(b)
}
func retainedSubscriptionHeaders(h http.Header) http.Header {
	out := make(http.Header)
	for _, k := range []string{"User-Agent", "Accept", "Accept-Language"} {
		if v, ok := h[http.CanonicalHeaderKey(k)]; ok {
			out[http.CanonicalHeaderKey(k)] = append([]string(nil), v...)
		}
	}
	return out
}

type subscriptionWireConn struct {
	net.Conn
	total *atomic.Int64
}

func (c *subscriptionWireConn) count(n int) error {
	if n > 0 && c.total.Add(int64(n)) > subscriptionFetchWireLimit {
		return errSubscriptionTooLarge
	}
	return nil
}

func (c *subscriptionWireConn) Read(p []byte) (int, error) {
	n, err := c.Conn.Read(p)
	if limitErr := c.count(n); limitErr != nil {
		return n, limitErr
	}
	return n, err
}

func (c *subscriptionWireConn) Write(p []byte) (int, error) {
	n, err := c.Conn.Write(p)
	if limitErr := c.count(n); limitErr != nil {
		return n, limitErr
	}
	return n, err
}

func fetchSubscriptionHop(ctx context.Context, connector subscriptionConnector, target *url.URL, headers http.Header, maxBytes int64, wire *atomic.Int64) (*SubscriptionFetchResult, string, error) {
	transport := &http.Transport{DialContext: func(ctx context.Context, network, address string) (net.Conn, error) {
		conn, err := connector.DialContext(ctx, network, address)
		if err != nil {
			return nil, err
		}
		return &subscriptionWireConn{Conn: conn, total: wire}, nil
	}, TLSHandshakeTimeout: 15 * time.Second, ResponseHeaderTimeout: 15 * time.Second, MaxResponseHeaderBytes: subscriptionFetchHeaderLimit, DisableCompression: true, DisableKeepAlives: true}
	defer transport.CloseIdleConnections()
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, target.String(), nil)
	if err != nil {
		return nil, "", errors.New("invalid subscription request")
	}
	request.Header = headers.Clone()
	client := &http.Client{Transport: transport, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	response, err := client.Do(request)
	if err != nil {
		return nil, "", err
	}
	defer response.Body.Close()
	for name, values := range response.Header {
		if len(name) > subscriptionFetchFieldLimit {
			return nil, "", errSubscriptionTooLarge
		}
		for _, value := range values {
			if len(value) > subscriptionFetchFieldLimit {
				return nil, "", errSubscriptionTooLarge
			}
		}
	}
	if response.StatusCode >= 300 && response.StatusCode < 400 {
		if location := response.Header.Get("Location"); location != "" {
			return nil, location, nil
		}
	}
	body, err := io.ReadAll(io.LimitReader(response.Body, maxBytes+1))
	if err != nil {
		return nil, "", err
	}
	if int64(len(body)) > maxBytes || wire.Load() > subscriptionFetchWireLimit {
		return nil, "", errSubscriptionTooLarge
	}
	resultHeaders := make(map[string][]string, len(response.Header))
	for name, values := range response.Header {
		resultHeaders[name] = append([]string(nil), values...)
	}
	return &SubscriptionFetchResult{Status: response.StatusCode, Headers: resultHeaders, BodyBase64: base64.StdEncoding.EncodeToString(body), FinalURL: target.String()}, "", nil
}

func subscriptionFetchMethodError(err error) error {
	switch {
	case errors.Is(err, errSubscriptionProtectedUnavailable), errors.Is(err, errSubscriptionProtectedRefused):
		return &MethodError{Code: "subscription_protection", Message: "protected subscription transport unavailable"}
	case errors.Is(err, errSubscriptionTooLarge):
		return &MethodError{Code: "subscription_too_large", Message: "subscription response exceeds size limit"}
	case errors.Is(err, errSubscriptionCancelled):
		return &MethodError{Code: "cancelled", Message: "subscription fetch cancelled"}
	case errors.Is(err, context.DeadlineExceeded):
		return &MethodError{Code: "subscription_timeout", Message: "subscription fetch timed out"}
	default:
		return &MethodError{Code: "subscription_transport", Message: "subscription fetch failed"}
	}
}

func handleCancelSubscriptionFetch(requestID string) bool { return cancelSubscriptionFetch(requestID) }
