package main

import "testing"

func TestAppendBoundedKeepsTheNewestValues(t *testing.T) {
	values := []int{1, 2}

	values = appendBounded(values, 3, 2)

	if len(values) != 2 || values[0] != 2 || values[1] != 3 {
		t.Fatalf("values = %v, want [2 3]", values)
	}
}

func TestAppendBoundedHandlesAZeroLimit(t *testing.T) {
	values := appendBounded([]int(nil), 1, 0)

	if len(values) != 0 {
		t.Fatalf("values = %v, want no values", values)
	}
}
