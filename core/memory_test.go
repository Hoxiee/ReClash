package main

import "testing"

func TestHandleGetMemoryStats(t *testing.T) {
	stats := handleGetMemoryStats()
	if stats.HeapInuse == 0 {
		t.Fatal("expected a non-zero heap in use")
	}
	runtimeTotal := stats.HeapInuse + stats.HeapIdle + stats.StackInuse + stats.RuntimeOther
	if runtimeTotal == 0 {
		t.Fatal("expected a non-zero runtime total")
	}
}
