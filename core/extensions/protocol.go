// Package extensions runs protocol extensions: separate executables speaking reclash-ext/1, exposed to mihomo as
// the "extension" outbound. testdata/protocol.json is the wire fixture the SDK in reclash-extensions tests against.
package extensions

// ProtocolVersion is the reclash-ext protocol this Core speaks.
const ProtocolVersion = 1

// SupportedProtocols is reported in CoreInfo.extensionProtocol.
var SupportedProtocols = []int{ProtocolVersion}

const (
	CommandRun      = "run"
	CommandDescribe = "describe"
	CommandVersion  = "version"
)

// Manifest is <core home>/extensions/<id>/<version>/manifest.json. Executable is relative to that directory and
// SHA256 is the lowercase hex digest of the executable, checked before every start.
type Manifest struct {
	ID         string   `json:"id"`
	Version    string   `json:"version"`
	Protocol   []int    `json:"protocol"`
	Schemes    []string `json:"schemes"`
	Executable string   `json:"executable"`
	SHA256     string   `json:"sha256"`
}

// Egress is the Core's loopback SOCKS5 endpoint every protocol socket of the extension must go through: TCP
// CONNECT and UDP ASSOCIATE, username/password auth (RFC 1929).
type Egress struct {
	SOCKS5   string `json:"socks5"`
	Username string `json:"username"`
	Password string `json:"password"`
}

// RunRequest is the single JSON object Core writes to the stdin of `<exe> run`. Closing stdin asks the extension
// to exit; Core kills the process group if it is still alive after StopGrace.
type RunRequest struct {
	Protocol int    `json:"protocol"`
	Link     string `json:"link"`
	Listen   string `json:"listen"`
	Egress   Egress `json:"egress"`
	DataDir  string `json:"dataDir"`
	LogLevel string `json:"logLevel"`
}

const (
	EventReady  = "ready"
	EventStatus = "status"
	EventFatal  = "fatal"

	StateOK       = "ok"
	StateDegraded = "degraded"
)

// Event is one JSON line on the stdout of `<exe> run`. ready comes once, before any status; fatal comes last,
// right before a non-zero exit. The front SOCKS5 always serves CONNECT, and UDP ASSOCIATE when UDP is true.
type Event struct {
	Event    string `json:"event"`
	SOCKS5   string `json:"socks5,omitempty"`
	Username string `json:"username,omitempty"`
	Password string `json:"password,omitempty"`
	UDP      bool   `json:"udp,omitempty"`
	State    string `json:"state,omitempty"`
	Message  string `json:"message,omitempty"`
}

// DescribeRequest is the stdin of `<exe> describe`; it must not touch the network.
type DescribeRequest struct {
	Links []string `json:"links"`
}

// DescribeResponse has one node per requested link, in order. A node with Error set is not importable.
type DescribeResponse struct {
	Nodes []DescribedNode `json:"nodes"`
}

type DescribedNode struct {
	Name   string `json:"name"`
	Server string `json:"server"`
	UDP    bool   `json:"udp"`
	Error  string `json:"error"`
}

// VersionResponse is the stdout of `<exe> version`.
type VersionResponse struct {
	ID       string `json:"id"`
	Version  string `json:"version"`
	Protocol []int  `json:"protocol"`
}
