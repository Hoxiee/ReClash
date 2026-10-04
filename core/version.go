package main

// CoreVersion is the semantic version of the ReClash engine that lives in
// core/ on top of the vendored mihomo. Bump it by hand when the engine's
// method contract or behaviour changes; it is independent of the mihomo tag
// reported in constant.Version.
const CoreVersion = "0.1.0"

// CoreCommit is the repository build identifier (git describe), injected via
// ldflags at build time. It stays "dev" for plain `go build`/`go test`.
var CoreCommit = "dev"
