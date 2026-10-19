//go:build !android

package main

import (
	"encoding/json"
	"errors"
	"io"
	"path/filepath"
	"regexp"
	"strings"
)

const macOSBootstrapLimit = 4096

var macOSSessionPattern = regexp.MustCompile(`^[0-9a-f]{32}$`)
var macOSHashPattern = regexp.MustCompile(`^[0-9a-f]{64}$`)
var macOSSocketPattern = regexp.MustCompile(`^/tmp/ReClashSocket_[0-9]+\.sock$`)

type macOSBootstrap struct {
	Version       int    `json:"version"`
	SessionID     string `json:"sessionId"`
	Address       string `json:"address"`
	HomeDir       string `json:"homeDir"`
	OwnerUID      uint32 `json:"ownerUid"`
	OwnerGID      uint32 `json:"ownerGid"`
	ClientPID     int    `json:"clientPid"`
	CorePath      string `json:"corePath"`
	CoreSHA256    string `json:"coreSha256"`
	AppIdentifier string `json:"appIdentifier"`
	AccountHome   string `json:"accountHome"`
}

func readMacOSBootstrap(reader io.Reader) (macOSBootstrap, error) {
	decoder := json.NewDecoder(io.LimitReader(reader, macOSBootstrapLimit+1))
	decoder.DisallowUnknownFields()
	var bootstrap macOSBootstrap
	if err := decoder.Decode(&bootstrap); err != nil {
		return bootstrap, err
	}
	var extra any
	if err := decoder.Decode(&extra); err != io.EOF {
		return bootstrap, errors.New("managed macOS bootstrap has trailing data")
	}
	if bootstrap.Version != 1 || !macOSSessionPattern.MatchString(bootstrap.SessionID) ||
		!macOSSocketPattern.MatchString(bootstrap.Address) || bootstrap.OwnerUID == 0 ||
		bootstrap.ClientPID <= 1 || !macOSHashPattern.MatchString(bootstrap.CoreSHA256) {
		return bootstrap, errors.New("invalid managed macOS bootstrap identity")
	}
	if bootstrap.AppIdentifier != "com.reclash" && bootstrap.AppIdentifier != "com.reclash.debug" {
		return bootstrap, errors.New("invalid managed macOS application identity")
	}
	if !canonicalMacOSPath(bootstrap.AccountHome) || !canonicalMacOSPath(bootstrap.HomeDir) {
		return bootstrap, errors.New("managed macOS home must be an absolute canonical path")
	}
	expectedHome := filepath.Join(bootstrap.AccountHome, "Library", "Application Support", bootstrap.AppIdentifier)
	if bootstrap.HomeDir != expectedHome {
		return bootstrap, errors.New("managed macOS home is outside the signed client's application scope")
	}
	expectedCore := filepath.Join("/Library/Application Support/ReClash/ManagedCore", bootstrap.AppIdentifier, bootstrap.CoreSHA256, "ReClashCore")
	if bootstrap.CorePath != expectedCore {
		return bootstrap, errors.New("managed macOS Core is outside its fixed hash-addressed scope")
	}
	return bootstrap, nil
}

func canonicalMacOSPath(path string) bool {
	return filepath.IsAbs(path) && filepath.Clean(path) == path &&
		len(path) < 1024 && !strings.ContainsAny(path, "\x00\r\n")
}
