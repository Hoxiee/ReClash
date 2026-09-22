package main

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"strings"
	"sync"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"

	"core/rcx"
)

var rcxIdentityState = struct {
	sync.Mutex
	salt   []byte
	opaque map[constant.Proxy]string
}{opaque: map[constant.Proxy]string{}}

func (rcxCoreRuntime) SetIdentitySalt(salt []byte) {
	rcxIdentityState.Lock()
	defer rcxIdentityState.Unlock()
	rcxIdentityState.salt = append([]byte(nil), salt...)
}

func rcxRouteKeys(nodes []constant.Proxy) map[constant.Proxy]string {
	rcxIdentityState.Lock()
	defer rcxIdentityState.Unlock()
	if len(rcxIdentityState.salt) == 0 {
		rcxIdentityState.salt = make([]byte, 32)
		if _, err := rand.Read(rcxIdentityState.salt); err != nil {
			return nil
		}
	}
	all := tunnel.AllProxies()
	counts := map[string]int{}
	for _, node := range nodes {
		counts[node.Name()]++
	}
	nextOpaque := map[constant.Proxy]string{}
	opaque := func(p constant.Proxy) string {
		id := rcxIdentityState.opaque[p]
		if id == "" {
			nonce := make([]byte, 32)
			if _, err := rand.Read(nonce); err != nil {
				return ""
			}
			id = hex.EncodeToString(nonce)
		}
		nextOpaque[p] = id
		return id
	}
	digest := func(value string) string {
		mac := hmac.New(sha256.New, rcxIdentityState.salt)
		_, _ = mac.Write([]byte(value))
		return "r2:" + hex.EncodeToString(mac.Sum(nil))
	}
	keys := map[constant.Proxy]string{}
	visiting := map[constant.Proxy]bool{}
	var resolve func(constant.Proxy) string
	resolve = func(p constant.Proxy) string {
		if key, ok := keys[p]; ok {
			return key
		}
		if visiting[p] {
			return digest("cycle:" + opaque(p))
		}
		visiting[p] = true
		defer delete(visiting, p)
		meta, ok := p.(interface {
			RouteFingerprint() string
			RouteDependency() string
		})
		value := ""
		if ok {
			value = meta.RouteFingerprint()
		}
		if value == "" || counts[p.Name()] > 1 {
			value = "opaque:" + opaque(p)
			if current, ok := p.(interface{ Now() string }); ok {
				value += ":" + current.Now()
			}
		}
		if ok && meta.RouteDependency() != "" {
			dependency := all[meta.RouteDependency()]
			if dependency == nil || visiting[dependency] {
				value = "dependent:" + opaque(p)
			} else {
				value += ":via:" + resolve(dependency)
			}
		}
		keys[p] = digest(value)
		return keys[p]
	}
	for _, node := range nodes {
		resolve(node)
	}
	rcxIdentityState.opaque = nextOpaque
	return keys
}

func rcxIngress(address string) string {
	return strings.ToLower(strings.TrimSpace(rcx.HostOf(address)))
}
