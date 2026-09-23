package doctor

func appendBounded[T any](values []T, value T, limit int) []T {
	if limit <= 0 {
		return values
	}
	if len(values) < limit {
		return append(values, value)
	}
	copy(values, values[1:])
	values[len(values)-1] = value
	return values
}
