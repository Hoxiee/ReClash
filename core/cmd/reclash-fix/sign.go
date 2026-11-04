package main

import (
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"
)

const (
	maxTTL     = 7 * 24 * time.Hour
	maxLinkLen = 2048
	linkPrefix = "reclash://fix?"
)

var (
	enc   = base64.RawURLEncoding
	ridRe = regexp.MustCompile(`^RC-[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}$`)
	// Plain actions take no arguments.
	plainActions = map[string]bool{
		"config.freePort": true, "config.ruleMode": true, "dns.ignoreSystemHosts": true,
		"profile.update": true, "proxy.clearOwn": true, "tunnel.freeDeviceName": true,
		"tunnel.restart": true, "profile.activate": true, "connections.reset": true,
		"core.restart": true, "overrides.reset": true,
	}
)

type Action struct {
	ID    string `json:"id"`
	Group string `json:"group,omitempty"`
	Node  string `json:"node,omitempty"`
}

type Payload struct {
	V     int      `json:"v"`
	Kid   string   `json:"kid"`
	Rid   string   `json:"rid"`
	Exp   int64    `json:"exp"`
	Nonce string   `json:"nonce"`
	Fix   []Action `json:"fix"`
}

func keyID(pub ed25519.PublicKey) string {
	sum := sha256.Sum256(pub)
	return enc.EncodeToString(sum[:8])
}

func headerValue(pub ed25519.PublicKey) string {
	return "ed25519:" + enc.EncodeToString(pub)
}

func parseAction(s string) (Action, error) {
	id, args, hasArgs := strings.Cut(s, ":")
	a := Action{ID: id}
	kv := map[string]string{}
	if hasArgs {
		for _, p := range strings.Split(args, ",") {
			k, v, ok := strings.Cut(p, "=")
			if !ok || k == "" || v == "" {
				return a, fmt.Errorf("bad argument %q in %q", p, s)
			}
			kv[k] = v
		}
	}
	switch {
	case id == "proxy.select":
		a.Group, a.Node = kv["group"], kv["node"]
		delete(kv, "group")
		delete(kv, "node")
		if a.Group == "" || a.Node == "" {
			return a, errors.New("proxy.select needs group and node")
		}
	case plainActions[id]:
	default:
		return a, fmt.Errorf("unknown action %q", id)
	}
	if len(kv) > 0 {
		return a, fmt.Errorf("unexpected arguments for %s", id)
	}
	return a, nil
}

func newNonce() string {
	b := make([]byte, 12)
	if _, err := rand.Read(b); err != nil {
		panic(err)
	}
	return enc.EncodeToString(b)
}

func buildLink(priv ed25519.PrivateKey, rid string, exp int64, nonce string, actions []string) (string, []byte, error) {
	if !ridRe.MatchString(rid) {
		return "", nil, fmt.Errorf("report id %q is not RC-XXXX-XXXX (Crockford base32)", rid)
	}
	if len(actions) == 0 {
		return "", nil, errors.New("no actions")
	}
	p := Payload{V: 1, Kid: keyID(priv.Public().(ed25519.PublicKey)), Rid: rid, Exp: exp, Nonce: nonce}
	for _, s := range actions {
		a, err := parseAction(s)
		if err != nil {
			return "", nil, err
		}
		p.Fix = append(p.Fix, a)
	}
	raw, err := json.Marshal(p)
	if err != nil {
		return "", nil, err
	}
	link := linkPrefix + "p=" + enc.EncodeToString(raw) + "&s=" + enc.EncodeToString(ed25519.Sign(priv, raw))
	if len(link) > maxLinkLen {
		return "", nil, fmt.Errorf("link is %d chars, limit %d", len(link), maxLinkLen)
	}
	return link, raw, nil
}

func sign(priv ed25519.PrivateKey, rid string, ttl time.Duration, actions []string) (string, time.Time, error) {
	if ttl <= 0 || ttl > maxTTL {
		return "", time.Time{}, fmt.Errorf("ttl must be in (0, %s]", maxTTL)
	}
	exp := time.Now().Add(ttl).Truncate(time.Second)
	link, _, err := buildLink(priv, rid, exp.Unix(), newNonce(), actions)
	return link, exp, err
}

// verifyLink checks the signature against any key of a comma-joined header
// value. It does not check expiry, nonce use or the report.
func verifyLink(header, link string) (*Payload, []byte, error) {
	rest, ok := strings.CutPrefix(link, linkPrefix)
	if !ok {
		return nil, nil, errors.New("not a reclash://fix link")
	}
	if len(link) > maxLinkLen {
		return nil, nil, errors.New("link longer than 2 KB")
	}
	var ps, ss string
	for _, kv := range strings.Split(rest, "&") {
		k, v, _ := strings.Cut(kv, "=")
		switch k {
		case "p":
			ps = v
		case "s":
			ss = v
		}
	}
	raw, err := enc.DecodeString(ps)
	if err != nil || len(raw) == 0 {
		return nil, nil, errors.New("payload is not base64url")
	}
	sig, err := enc.DecodeString(ss)
	if err != nil {
		return nil, nil, errors.New("signature is not base64url")
	}
	var p Payload
	if err := strictUnmarshal(raw, &p); err != nil {
		return nil, raw, fmt.Errorf("bad payload: %w", err)
	}
	for _, k := range strings.Split(header, ",") {
		b, err := enc.DecodeString(strings.TrimPrefix(strings.TrimSpace(k), "ed25519:"))
		if err != nil || len(b) != ed25519.PublicKeySize {
			return &p, raw, errors.New("bad public key in header")
		}
		pub := ed25519.PublicKey(b)
		if keyID(pub) != p.Kid {
			continue
		}
		if !ed25519.Verify(pub, raw, sig) {
			return &p, raw, errors.New("signature does not verify")
		}
		return &p, raw, nil
	}
	return &p, raw, errors.New("kid matches no key in header")
}

func strictUnmarshal(raw []byte, v any) error {
	d := json.NewDecoder(strings.NewReader(string(raw)))
	d.DisallowUnknownFields()
	return d.Decode(v)
}
