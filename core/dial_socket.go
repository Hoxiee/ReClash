//go:build !android && !windows

package core

import (
	"fmt"
	"net"
	"strconv"
)

func dial(arg string) (net.Conn, error) {
	var connection net.Conn
	var err error
	if _, numeric := strconv.Atoi(arg); numeric != nil {
		connection, err = net.Dial("unix", arg)
	} else {
		connection, err = net.Dial("tcp", fmt.Sprintf("127.0.0.1:%s", arg))
	}
	if err != nil {
		return nil, err
	}
	if err := verifyDesktopConnection(connection); err != nil {
		_ = connection.Close()
		return nil, err
	}
	return connection, nil
}
