package main

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"

	"github.com/metacubex/mihomo/component/geodata"
	"github.com/metacubex/mihomo/component/geodata/router"
	C "github.com/metacubex/mihomo/constant"

	"google.golang.org/protobuf/proto"
)

func geoSiteFixture(t *testing.T, domain string) []byte {
	t.Helper()
	list := &router.GeoSiteList{
		Entry: []*router.GeoSite{
			{
				CountryCode: "CN",
				Domain: []*router.Domain{
					{Type: router.Domain_Domain, Value: domain},
				},
			},
			{
				CountryCode: "PRIVATE",
				Domain: []*router.Domain{
					{Type: router.Domain_Domain, Value: "localhost"},
				},
			},
		},
	}
	data, err := proto.Marshal(list)
	if err != nil {
		t.Fatalf("marshal geosite fixture: %v", err)
	}
	return data
}

func geoIPFixture(t *testing.T, ip []byte) []byte {
	t.Helper()
	list := &router.GeoIPList{
		Entry: []*router.GeoIP{
			{
				CountryCode: "CN",
				Cidr:        []*router.CIDR{{Ip: ip, Prefix: 8}},
			},
		},
	}
	data, err := proto.Marshal(list)
	if err != nil {
		t.Fatalf("marshal geoip fixture: %v", err)
	}
	return data
}

func geoHome(t *testing.T) string {
	t.Helper()
	previous := C.Path.HomeDir()
	home := t.TempDir()
	C.SetHomeDir(home)
	t.Cleanup(func() { C.SetHomeDir(previous) })
	return home
}

func writeGeoAsset(t *testing.T, home string, name string, data []byte) {
	t.Helper()
	if err := os.WriteFile(filepath.Join(home, name), data, 0o644); err != nil {
		t.Fatalf("write %s: %v", name, err)
	}
}

func chunkRoot(home string) string {
	return filepath.Join(home, geoChunkDirName)
}

func loadSite(t *testing.T, loaderName string, file string, tag string) []*router.Domain {
	t.Helper()
	loader, err := geodata.GetGeoDataLoader(loaderName)
	if err != nil {
		t.Fatalf("get %s loader: %v", loaderName, err)
	}
	domains, err := loader.LoadSiteByPath(file, tag)
	if err != nil {
		t.Fatalf("load %s from %s: %v", tag, file, err)
	}
	return domains
}

func TestGeoChunkServesTagWithoutRescanningDatabase(t *testing.T) {
	home := geoHome(t)
	original := geoSiteFixture(t, "example.com")
	writeGeoAsset(t, home, "geosite.dat", original)

	if domains := loadSite(t, "memconservative", "geosite.dat", "cn"); len(domains) != 1 ||
		domains[0].Value != "example.com" {
		t.Fatalf("unexpected first load: %v", domains)
	}

	asset := filepath.Join(home, "geosite.dat")
	info, err := os.Stat(asset)
	if err != nil {
		t.Fatalf("stat asset: %v", err)
	}
	if err := os.WriteFile(asset, bytes.Repeat([]byte{0xff}, len(original)), 0o644); err != nil {
		t.Fatalf("corrupt asset: %v", err)
	}
	if err := os.Chtimes(asset, info.ModTime(), info.ModTime()); err != nil {
		t.Fatalf("restore mtime: %v", err)
	}

	domains := loadSite(t, "memconservative", "geosite.dat", "cn")
	if len(domains) != 1 || domains[0].Value != "example.com" {
		t.Fatalf("chunk was not reused: %v", domains)
	}
}

func TestGeoChunkFollowsDatabaseUpdateAndPrunesStaleStamps(t *testing.T) {
	home := geoHome(t)
	writeGeoAsset(t, home, "geosite.dat", geoSiteFixture(t, "old.example"))
	loadSite(t, "standard", "geosite.dat", "cn")

	stamps, err := os.ReadDir(chunkRoot(home))
	if err != nil || len(stamps) != 1 {
		t.Fatalf("expected one chunk stamp, got %v (%v)", stamps, err)
	}

	writeGeoAsset(t, home, "geosite.dat", geoSiteFixture(t, "new.example.org"))
	domains := loadSite(t, "standard", "geosite.dat", "cn")
	if len(domains) != 1 || domains[0].Value != "new.example.org" {
		t.Fatalf("stale chunk served after update: %v", domains)
	}

	stamps, err = os.ReadDir(chunkRoot(home))
	if err != nil || len(stamps) != 1 {
		t.Fatalf("stale stamp kept: %v (%v)", stamps, err)
	}
	if _, err := os.Stat(filepath.Join(chunkRoot(home), stamps[0].Name(), "cn.pb")); err != nil {
		t.Fatalf("chunk missing for current stamp: %v", err)
	}
}

func TestGeoChunkLoaderKeepsByBytesUsableForBothNames(t *testing.T) {
	geoHome(t)
	site := geoSiteFixture(t, "bytes.example")
	ips := geoIPFixture(t, []byte{10, 0, 0, 0})

	for _, name := range []string{"standard", "memconservative"} {
		loader, err := geodata.GetGeoDataLoader(name)
		if err != nil {
			t.Fatalf("get %s loader: %v", name, err)
		}
		domains, err := loader.LoadSiteByBytes(site, "cn")
		if err != nil || len(domains) != 1 || domains[0].Value != "bytes.example" {
			t.Fatalf("%s LoadSiteByBytes: %v (%v)", name, domains, err)
		}
		cidrs, err := loader.LoadIPByBytes(ips, "cn")
		if err != nil || len(cidrs) != 1 || cidrs[0].Prefix != 8 {
			t.Fatalf("%s LoadIPByBytes: %v (%v)", name, cidrs, err)
		}
	}
}

func TestGeoChunkTagStaysAFileName(t *testing.T) {
	if got := geoChunkTag("GeoLocation-CN"); got != "geolocation-cn" {
		t.Fatalf("safe tag rewritten: %s", got)
	}
	unsafe := geoChunkTag("../../etc/passwd")
	if len(unsafe) != 32 {
		t.Fatalf("unsafe tag not hashed: %s", unsafe)
	}
	if geoChunkTag("") == geoChunkTag("cn") {
		t.Fatal("empty tag collides with a real one")
	}
}
