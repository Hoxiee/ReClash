package main

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/metacubex/mihomo/component/geodata"
	"github.com/metacubex/mihomo/component/geodata/memconservative"
	"github.com/metacubex/mihomo/component/geodata/router"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"

	"google.golang.org/protobuf/proto"
)

// A geo database is scanned from the front for every tag a profile mentions, so
// a cold start pays one scan of a twenty-megabyte file per rule. The scanned
// section is small and self-contained, so it is kept beside the database and
// reused until the database itself changes.
const geoChunkDirName = "geo-chunks"

// Both loader names get the same treatment: which one a profile asks for should
// not decide whether a cold start rescans everything.
func init() {
	for _, name := range []string{"standard", "memconservative"} {
		geodata.RegisterGeoDataLoaderImplementationCreator(name, newGeoChunkLoader)
	}
}

func newGeoChunkLoader() geodata.LoaderImplementation {
	return geoChunkLoader{}
}

type geoChunkLoader struct{}

func (geoChunkLoader) LoadSiteByPath(filename, list string) ([]*router.Domain, error) {
	site := &router.GeoSite{}
	if err := loadGeoSection(filename, list, site, func(data []byte) (proto.Message, error) {
		var sites router.GeoSiteList
		if err := proto.Unmarshal(data, &sites); err != nil {
			return nil, err
		}
		for _, entry := range sites.Entry {
			if strings.EqualFold(entry.CountryCode, list) {
				return entry, nil
			}
		}
		return nil, fmt.Errorf("list %s not found", list)
	}); err != nil {
		return nil, err
	}
	return site.Domain, nil
}

func (geoChunkLoader) LoadSiteByBytes(geositeBytes []byte, list string) ([]*router.Domain, error) {
	var sites router.GeoSiteList
	if err := proto.Unmarshal(geositeBytes, &sites); err != nil {
		return nil, err
	}
	for _, entry := range sites.Entry {
		if strings.EqualFold(entry.CountryCode, list) {
			return entry.Domain, nil
		}
	}
	return nil, fmt.Errorf("list %s not found", list)
}

func (geoChunkLoader) LoadIPByPath(filename, country string) ([]*router.CIDR, error) {
	geoip := &router.GeoIP{}
	if err := loadGeoSection(filename, country, geoip, func(data []byte) (proto.Message, error) {
		var ips router.GeoIPList
		if err := proto.Unmarshal(data, &ips); err != nil {
			return nil, err
		}
		for _, entry := range ips.Entry {
			if strings.EqualFold(entry.CountryCode, country) {
				return entry, nil
			}
		}
		return nil, fmt.Errorf("country %s not found", country)
	}); err != nil {
		return nil, err
	}
	return geoip.Cidr, nil
}

func (geoChunkLoader) LoadIPByBytes(geoipBytes []byte, country string) ([]*router.CIDR, error) {
	var ips router.GeoIPList
	if err := proto.Unmarshal(geoipBytes, &ips); err != nil {
		return nil, err
	}
	for _, entry := range ips.Entry {
		if strings.EqualFold(entry.CountryCode, country) {
			return entry.Cidr, nil
		}
	}
	return nil, fmt.Errorf("country %s not found", country)
}

func loadGeoSection(
	filename string,
	tag string,
	into proto.Message,
	findEntry func(whole []byte) (proto.Message, error),
) error {
	asset := C.Path.GetAssetLocation(filename)
	chunk, family, cacheable := geoChunkPath(asset, tag)
	if cacheable {
		if data, err := os.ReadFile(chunk); err == nil && proto.Unmarshal(data, into) == nil {
			return nil
		}
	}

	defer runtime.GC()

	if data, err := memconservative.Decode(asset, tag); err == nil {
		if err := proto.Unmarshal(data, into); err != nil {
			return err
		}
		storeGeoChunk(chunk, family, data, cacheable)
		return nil
	}

	whole, err := os.ReadFile(asset)
	if err != nil {
		return fmt.Errorf("failed to read geodata file: %s, base error: %w", filename, err)
	}
	entry, err := findEntry(whole)
	if err != nil {
		return err
	}
	data, err := proto.Marshal(entry)
	if err != nil {
		return err
	}
	if err := proto.Unmarshal(data, into); err != nil {
		return err
	}
	storeGeoChunk(chunk, family, data, cacheable)
	return nil
}

// Size and mtime are what an update changes, so they name the chunk directory
// and a stale one is spotted without reading anything.
func geoChunkPath(asset string, tag string) (chunk string, family string, cacheable bool) {
	info, err := os.Stat(asset)
	if err != nil || info.Size() == 0 {
		return "", "", false
	}
	family = strings.ToLower(filepath.Base(asset)) + "-"
	stamp := fmt.Sprintf("%s%d-%d", family, info.Size(), info.ModTime().UnixNano())
	root := filepath.Join(filepath.Dir(asset), geoChunkDirName)
	return filepath.Join(root, stamp, geoChunkTag(tag)+".pb"), family, true
}

func geoChunkTag(tag string) string {
	tag = strings.ToLower(tag)
	if len(tag) == 0 || len(tag) > 64 || strings.IndexFunc(tag, isUnsafeGeoTagRune) >= 0 {
		digest := sha256.Sum256([]byte(tag))
		return hex.EncodeToString(digest[:16])
	}
	return tag
}

func isUnsafeGeoTagRune(r rune) bool {
	switch {
	case r >= 'a' && r <= 'z', r >= '0' && r <= '9':
		return false
	case r == '-', r == '_', r == '.':
		return false
	}
	return true
}

func storeGeoChunk(chunk string, family string, data []byte, cacheable bool) {
	if !cacheable || len(data) == 0 {
		return
	}
	dir := filepath.Dir(chunk)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		log.Debugln("[GEO] chunk cache unavailable: %s", err)
		return
	}
	temp := chunk + ".tmp"
	if err := os.WriteFile(temp, data, 0o644); err != nil {
		log.Debugln("[GEO] chunk not written: %s", err)
		return
	}
	if err := os.Rename(temp, chunk); err != nil {
		_ = os.Remove(temp)
		log.Debugln("[GEO] chunk not published: %s", err)
		return
	}
	pruneGeoChunks(dir, family)
}

func pruneGeoChunks(keep string, family string) {
	root, current := filepath.Split(keep)
	entries, err := os.ReadDir(root)
	if err != nil {
		return
	}
	for _, entry := range entries {
		name := entry.Name()
		if name == current || !strings.HasPrefix(name, family) {
			continue
		}
		if err := os.RemoveAll(filepath.Join(root, name)); err != nil && !errors.Is(err, os.ErrNotExist) {
			log.Debugln("[GEO] stale chunks kept: %s", err)
		}
	}
}
