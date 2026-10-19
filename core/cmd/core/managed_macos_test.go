//go:build !android

package main

import (
	"bytes"
	"encoding/json"
	"strings"
	"testing"
)

func validMacOSBootstrap() macOSBootstrap {
	return macOSBootstrap{
		Version: 1, SessionID: strings.Repeat("a", 32),
		Address: "/tmp/ReClashSocket_42.sock", OwnerUID: 501, OwnerGID: 20, ClientPID: 123,
		HomeDir:    "/Users/test/Library/Application Support/com.reclash",
		CoreSHA256: strings.Repeat("b", 64), AppIdentifier: "com.reclash", AccountHome: "/Users/test",
		CorePath: "/Library/Application Support/ReClash/ManagedCore/com.reclash/" + strings.Repeat("b", 64) + "/ReClashCore",
	}
}

func TestManagedMacOSBootstrap(t *testing.T) {
	value := validMacOSBootstrap()
	data, err := json.Marshal(value)
	if err != nil {
		t.Fatal(err)
	}
	parsed, err := readMacOSBootstrap(bytes.NewReader(data))
	if err != nil || parsed != value {
		t.Fatalf("valid bootstrap: got %+v, error %v", parsed, err)
	}
}

func TestManagedMacOSBootstrapRejectsUnscopedValues(t *testing.T) {
	cases := map[string]func(*macOSBootstrap){
		"root user": func(v *macOSBootstrap) { v.OwnerUID = 0 },
		"version":   func(v *macOSBootstrap) { v.Version = 2 },
		"session":   func(v *macOSBootstrap) { v.SessionID = strings.Repeat("A", 32) },
		"pid":       func(v *macOSBootstrap) { v.ClientPID = 1 },
		"tcp":       func(v *macOSBootstrap) { v.Address = "9090" },
		"socket":    func(v *macOSBootstrap) { v.Address = "/tmp/other.sock" },
		"home":      func(v *macOSBootstrap) { v.HomeDir = "/etc" },
		"traversal": func(v *macOSBootstrap) { v.AccountHome = "/Users/test/../root" },
		"binary":    func(v *macOSBootstrap) { v.CorePath = "/bin/sh" },
		"hash":      func(v *macOSBootstrap) { v.CoreSHA256 = strings.Repeat("B", 64) },
		"alpha":     func(v *macOSBootstrap) { v.AppIdentifier = "com.reclash.alpha" },
	}
	for name, mutate := range cases {
		t.Run(name, func(t *testing.T) {
			value := validMacOSBootstrap()
			mutate(&value)
			data, _ := json.Marshal(value)
			if _, err := readMacOSBootstrap(bytes.NewReader(data)); err == nil {
				t.Fatal("unscoped bootstrap was accepted")
			}
		})
	}
}

func TestManagedMacOSBootstrapRejectsUnknownOrTrailingFields(t *testing.T) {
	data, _ := json.Marshal(validMacOSBootstrap())
	for _, invalid := range [][]byte{
		append(append([]byte{}, data...), []byte("{}")...),
		append(append([]byte{}, data[:len(data)-1]...), []byte(`,"execute":"/bin/sh"}`)...),
		[]byte(strings.Repeat(" ", macOSBootstrapLimit) + string(data)),
	} {
		if _, err := readMacOSBootstrap(bytes.NewReader(invalid)); err == nil {
			t.Fatal("invalid bootstrap frame was accepted")
		}
	}
}
