package core

import (
	"context"
	"os/exec"
	"strings"
	"time"
)

func readPowerState() (rcxPowerState, bool) {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	out, err := exec.CommandContext(ctx, "/usr/bin/pmset", "-g", "batt").Output()
	if err != nil {
		return rcxPowerState{}, false
	}
	switch text := string(out); {
	case strings.Contains(text, "'Battery Power'"):
		return rcxPowerState{onBattery: true}, true
	case strings.Contains(text, "'AC Power'"):
		return rcxPowerState{}, true
	}
	return rcxPowerState{}, false
}
