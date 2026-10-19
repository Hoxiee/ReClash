//go:build windows

package core

import (
	"net"

	"github.com/Microsoft/go-winio"
)

func dial(path string) (net.Conn, error) {
	connection, err := winio.DialPipe(path, nil)
	if err != nil {
		return nil, err
	}
	if err := verifyDesktopConnection(connection); err != nil {
		_ = connection.Close()
		return nil, err
	}
	return connection, nil
}
