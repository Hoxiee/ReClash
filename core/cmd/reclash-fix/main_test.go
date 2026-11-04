package main

import (
	"crypto/ed25519"
	"strings"
	"testing"
	"time"
)

func zeroKey() ed25519.PrivateKey { return ed25519.NewKeyFromSeed(make([]byte, 32)) }

func hdr(priv ed25519.PrivateKey) string { return headerValue(priv.Public().(ed25519.PublicKey)) }

func TestFixedVector(t *testing.T) {
	priv := zeroKey()
	pub := priv.Public().(ed25519.PublicKey)
	const wantHeader = "ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik"
	if got := headerValue(pub); got != wantHeader {
		t.Fatalf("header %s", got)
	}
	link, _, err := buildLink(priv, "RC-7K3F-92QD", 1767225600, "AAECAwQFBgcICQoL",
		[]string{"profile.update", "proxy.select:group=Auto,node=NL-1"})
	if err != nil {
		t.Fatal(err)
	}
	const wantLink = "reclash://fix?p=eyJ2IjoxLCJraWQiOiJFNTQ1UU9aTFZKRSIsInJpZCI6IlJDLTdLM0YtOTJRRCIsImV4cCI6MTc2NzIyNTYwMCwibm9uY2UiOiJBQUVDQXdRRkJnY0lDUW9MIiwiZml4IjpbeyJpZCI6InByb2ZpbGUudXBkYXRlIn0seyJpZCI6InByb3h5LnNlbGVjdCIsImdyb3VwIjoiQXV0byIsIm5vZGUiOiJOTC0xIn1dfQ&s=XEdYg90ecSzT7cV1dRxH9cCVLpw01KXGiWC1Lz4iUD0kYga2zSoZwr1VQnkXVkVlyx5D3L3fGx_ursuvQvmBDQ"
	if link != wantLink {
		t.Fatalf("link %s", link)
	}
	if keyID(pub) != "E545QOZLVJE" {
		t.Fatalf("kid %s", keyID(pub))
	}
}

func TestRoundTrip(t *testing.T) {
	priv := zeroKey()
	link, exp, err := sign(priv, "RC-7K3F-92QD", time.Hour, []string{"profile.update", "proxy.select:group=A,node=B"})
	if err != nil {
		t.Fatal(err)
	}
	if time.Until(exp) > time.Hour {
		t.Fatal("exp too far")
	}
	p, _, err := verifyLink(hdr(priv), link)
	if err != nil {
		t.Fatal(err)
	}
	if p.Rid != "RC-7K3F-92QD" || len(p.Fix) != 2 || p.Fix[1].Node != "B" {
		t.Fatalf("%+v", p)
	}
}

func TestTamperedPayload(t *testing.T) {
	priv := zeroKey()
	link, _, _ := buildLink(priv, "RC-7K3F-92QD", 1, "n", []string{"profile.update"})
	other, _, _ := buildLink(priv, "RC-7K3F-92QD", 2, "n", []string{"profile.update"})
	tampered := strings.SplitN(other, "&s=", 2)[0] + "&s=" + strings.SplitN(link, "&s=", 2)[1]
	if _, _, err := verifyLink(hdr(priv), tampered); err == nil {
		t.Fatal("tampered link verified")
	}
}

func TestWrongKey(t *testing.T) {
	priv := zeroKey()
	link, _, _ := buildLink(priv, "RC-7K3F-92QD", 1, "n", []string{"profile.update"})
	seed := make([]byte, 32)
	seed[0] = 1
	if _, _, err := verifyLink(hdr(ed25519.NewKeyFromSeed(seed)), link); err == nil {
		t.Fatal("wrong key verified")
	}
}

func TestRejects(t *testing.T) {
	priv := zeroKey()
	rid := "RC-7K3F-92QD"
	if _, _, err := sign(priv, rid, 169*time.Hour, []string{"profile.update"}); err == nil {
		t.Error("ttl > 168h accepted")
	}
	if _, _, err := sign(priv, rid, time.Hour, []string{"rm.rf"}); err == nil {
		t.Error("unknown action accepted")
	}
	if _, _, err := sign(priv, rid, time.Hour, []string{"proxy.select:group=A"}); err == nil {
		t.Error("proxy.select without node accepted")
	}
	if _, _, err := sign(priv, "RC-7K3F-92QU", time.Hour, []string{"profile.update"}); err == nil {
		t.Error("bad report id accepted")
	}
}
