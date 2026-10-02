//go:build windows && !(android && cgo)

package main

import (
	"context"
	"net"

	"github.com/Microsoft/go-winio"
)

func dial(path string) (net.Conn, error) {
	ctx, cancel := context.WithTimeout(context.Background(), windowsBootstrapTimeout)
	defer cancel()
	connection, err := winio.DialPipeAccessImpLevel(ctx, path, windowsPipeAccess, winio.PipeImpLevelAnonymous)
	if err != nil {
		return nil, err
	}
	if err := verifyWindowsRPCServer(connection); err != nil {
		connection.Close()
		return nil, err
	}
	return connection, nil
}
