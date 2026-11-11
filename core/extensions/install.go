package extensions

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"slices"
	"sort"
	"strconv"
	"strings"
)

const (
	extensionsDirName = "extensions"
	dataDirName       = "data"
	manifestName      = "manifest.json"
	maxManifestSize   = 64 << 10
)

var validID = regexp.MustCompile(`^[a-z0-9][a-z0-9._-]{0,63}$`)

type installation struct {
	Manifest
	dir string
}

func (i installation) executable() string {
	return filepath.Join(i.dir, i.Executable)
}

func extensionsRoot(home string) string {
	return filepath.Join(home, extensionsDirName)
}

// findInstallation picks the highest installed version of id that speaks ProtocolVersion.
func findInstallation(home, id string) (installation, error) {
	if !validID.MatchString(id) {
		return installation{}, fmt.Errorf("invalid extension id %q", id)
	}
	root := filepath.Join(extensionsRoot(home), id)
	entries, err := os.ReadDir(root)
	if errors.Is(err, fs.ErrNotExist) {
		return installation{}, errors.New("not installed")
	}
	if err != nil {
		return installation{}, err
	}
	var best *installation
	var incompatible []int
	for _, entry := range entries {
		if !entry.IsDir() || entry.Name() == dataDirName {
			continue
		}
		dir := filepath.Join(root, entry.Name())
		manifest, err := readManifest(dir)
		if err != nil || manifest.ID != id || manifest.Version != entry.Name() {
			continue
		}
		if !slices.Contains(manifest.Protocol, ProtocolVersion) {
			incompatible = append(incompatible, manifest.Protocol...)
			continue
		}
		if best == nil || compareVersions(manifest.Version, best.Version) > 0 {
			best = &installation{Manifest: manifest, dir: dir}
		}
	}
	if best != nil {
		return *best, nil
	}
	if len(incompatible) > 0 {
		return installation{}, fmt.Errorf("installed version speaks protocol %v, this Core speaks %v", incompatible, SupportedProtocols)
	}
	return installation{}, errors.New("not installed")
}

func readManifest(dir string) (Manifest, error) {
	file, err := os.Open(filepath.Join(dir, manifestName))
	if err != nil {
		return Manifest{}, err
	}
	defer file.Close()
	var manifest Manifest
	if err := json.NewDecoder(io.LimitReader(file, maxManifestSize)).Decode(&manifest); err != nil {
		return Manifest{}, err
	}
	if !filepath.IsLocal(manifest.Executable) {
		return Manifest{}, fmt.Errorf("executable %q escapes its directory", manifest.Executable)
	}
	return manifest, nil
}

func verifyExecutable(inst installation) error {
	file, err := os.Open(inst.executable())
	if errors.Is(err, fs.ErrNotExist) {
		return fmt.Errorf("executable %s is missing", inst.Executable)
	}
	if err != nil {
		return err
	}
	defer file.Close()
	hash := sha256.New()
	if _, err := io.Copy(hash, file); err != nil {
		return err
	}
	if !strings.EqualFold(hex.EncodeToString(hash.Sum(nil)), inst.SHA256) {
		return fmt.Errorf("executable %s does not match its manifest hash", inst.Executable)
	}
	return nil
}

func dataDir(home, id, link string) string {
	sum := sha256.Sum256([]byte(link))
	return filepath.Join(extensionsRoot(home), id, dataDirName, hex.EncodeToString(sum[:])[:16])
}

func installedIDs(home string) []string {
	entries, err := os.ReadDir(extensionsRoot(home))
	if err != nil {
		return nil
	}
	var ids []string
	for _, entry := range entries {
		if entry.IsDir() && validID.MatchString(entry.Name()) {
			ids = append(ids, entry.Name())
		}
	}
	sort.Strings(ids)
	return ids
}

// compareVersions orders dot-separated versions numerically where both parts are numbers.
func compareVersions(a, b string) int {
	left, right := strings.Split(a, "."), strings.Split(b, ".")
	for i := 0; i < max(len(left), len(right)); i++ {
		var l, r string
		if i < len(left) {
			l = left[i]
		}
		if i < len(right) {
			r = right[i]
		}
		ln, lerr := strconv.Atoi(l)
		rn, rerr := strconv.Atoi(r)
		switch {
		case lerr == nil && rerr == nil && ln != rn:
			if ln < rn {
				return -1
			}
			return 1
		case (lerr != nil || rerr != nil) && l != r:
			return strings.Compare(l, r)
		}
	}
	return 0
}
