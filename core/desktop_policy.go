package core

import (
	"crypto/rand"
	"errors"
	"io"
	"io/fs"
	"net"
	"os"
	"path/filepath"
	"strings"
	"sync"
)

var desktopPolicy struct {
	sync.RWMutex
	root       *os.Root
	home       string
	verifier   func(net.Conn) error
	configured bool
}

func ConfigureDesktopLaunch(home string, verifier func(net.Conn) error) error {
	var root *os.Root
	if home != "" {
		if !filepath.IsAbs(home) {
			return errors.New("desktop home must be absolute")
		}
		canonical, err := filepath.EvalSymlinks(home)
		if err != nil {
			return err
		}
		info, err := os.Stat(canonical)
		if err != nil || !info.IsDir() {
			return errors.New("desktop home must be a directory")
		}
		home = filepath.Clean(canonical)
		root, err = os.OpenRoot(home)
		if err != nil {
			return err
		}
	}
	desktopPolicy.Lock()
	defer desktopPolicy.Unlock()
	if desktopPolicy.configured {
		if root != nil {
			_ = root.Close()
		}
		return errors.New("desktop launch policy is already configured")
	}
	desktopPolicy.root = root
	desktopPolicy.home = home
	desktopPolicy.verifier = verifier
	desktopPolicy.configured = true
	return nil
}

func verifyDesktopConnection(connection net.Conn) error {
	desktopPolicy.RLock()
	verifier := desktopPolicy.verifier
	desktopPolicy.RUnlock()
	if verifier == nil {
		return nil
	}
	return verifier(connection)
}

func permittedDesktopHome(home string) bool {
	desktopPolicy.RLock()
	expected := desktopPolicy.home
	desktopPolicy.RUnlock()
	if expected == "" {
		return true
	}
	if !filepath.IsAbs(home) {
		return false
	}
	canonical, err := filepath.EvalSymlinks(home)
	return err == nil && filepath.Clean(canonical) == expected
}

func desktopFileRoot() (*os.Root, string) {
	desktopPolicy.RLock()
	defer desktopPolicy.RUnlock()
	return desktopPolicy.root, desktopPolicy.home
}

var errDesktopPath = &MethodError{Code: "path_not_allowed", Message: "Core file access is limited to its application home"}

func desktopRelativePath(home, path string) (string, error) {
	if !filepath.IsAbs(path) {
		return "", errDesktopPath
	}
	relative, err := filepath.Rel(home, filepath.Clean(path))
	if err != nil || !filepath.IsLocal(relative) {
		return "", errDesktopPath
	}
	return relative, nil
}

func readCoreFile(path string) ([]byte, error) {
	root, home := desktopFileRoot()
	if root == nil {
		return os.ReadFile(path)
	}
	relative, err := desktopRelativePath(home, path)
	if err != nil {
		return nil, err
	}
	file, err := root.Open(relative)
	if err != nil {
		return nil, errDesktopPath
	}
	defer file.Close()
	info, err := file.Stat()
	if err != nil || !info.Mode().IsRegular() || !singleLinkedCoreFile(file, info) {
		return nil, errDesktopPath
	}
	return io.ReadAll(file)
}

func makeCoreDirectory(path string, mode fs.FileMode) error {
	root, home := desktopFileRoot()
	if root == nil {
		return os.MkdirAll(path, mode)
	}
	relative, err := desktopRelativePath(home, path)
	if err != nil {
		return err
	}
	return root.MkdirAll(relative, mode)
}

func createCoreTempFile(directory, pattern string) (*os.File, error) {
	root, home := desktopFileRoot()
	if root == nil {
		return os.CreateTemp(directory, pattern)
	}
	relative, err := desktopRelativePath(home, directory)
	if err != nil {
		return nil, err
	}
	prefix, suffix, _ := strings.Cut(pattern, "*")
	name := filepath.Join(relative, prefix+rand.Text()+suffix)
	return root.OpenFile(name, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o600)
}

func removeCorePath(path string, recursive bool) error {
	root, home := desktopFileRoot()
	if root == nil {
		if recursive {
			return os.RemoveAll(path)
		}
		return os.Remove(path)
	}
	relative, err := desktopRelativePath(home, path)
	if err != nil || relative == "." {
		return errDesktopPath
	}
	if recursive {
		return root.RemoveAll(relative)
	}
	return root.Remove(relative)
}

func renameCoreFile(source, destination string) error {
	root, home := desktopFileRoot()
	if root == nil {
		return os.Rename(source, destination)
	}
	from, err := desktopRelativePath(home, source)
	if err != nil {
		return err
	}
	to, err := desktopRelativePath(home, destination)
	if err != nil {
		return err
	}
	return root.Rename(from, to)
}
