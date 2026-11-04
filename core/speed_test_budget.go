package core

import (
	"crypto/rand"
	"errors"
	"io"
	"sync"
)

type speedTestDirection uint8

const (
	speedTestProbe speedTestDirection = iota
	speedTestDownload
	speedTestUpload
)

type speedTestBudget struct {
	mu       sync.Mutex
	limits   [3]int64
	used     [3]int64
	reserved [3]int64
}

func newSpeedTestBudget(limit int64) *speedTestBudget {
	limit = max(0, limit)
	probe := min(limit/16, 512*1024)
	remaining := limit - probe
	return &speedTestBudget{limits: [3]int64{probe, remaining / 2, remaining - remaining/2}}
}

func (b *speedTestBudget) reserve(direction speedTestDirection, wanted, unit int64) *speedTestReservation {
	b.mu.Lock()
	defer b.mu.Unlock()
	available := b.limits[direction] - b.used[direction] - b.reserved[direction]
	amount := min(max(wanted, 0), available)
	if unit > 1 {
		amount = amount / unit * unit
	}
	if amount <= 0 {
		return nil
	}
	b.reserved[direction] += amount
	return &speedTestReservation{budget: b, direction: direction, amount: amount, remaining: amount}
}

func (b *speedTestBudget) spent() int64 {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.used[0] + b.used[1] + b.used[2]
}

func (b *speedTestBudget) available(direction speedTestDirection) int64 {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.limits[direction] - b.used[direction] - b.reserved[direction]
}

func (b *speedTestBudget) fraction(direction speedTestDirection) float64 {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.limits[direction] == 0 {
		return 1
	}
	return float64(b.used[direction]) / float64(b.limits[direction])
}

type speedTestReservation struct {
	budget    *speedTestBudget
	direction speedTestDirection
	amount    int64
	remaining int64
	closed    bool
}

func (r *speedTestReservation) consume(count int64) error {
	r.budget.mu.Lock()
	defer r.budget.mu.Unlock()
	if count < 0 || r.closed || count > r.remaining {
		return errors.New("speed test payload exceeded its reservation")
	}
	r.remaining -= count
	r.budget.reserved[r.direction] -= count
	r.budget.used[r.direction] += count
	return nil
}

func (r *speedTestReservation) release() {
	r.budget.mu.Lock()
	defer r.budget.mu.Unlock()
	if !r.closed {
		r.budget.reserved[r.direction] -= r.remaining
		r.remaining = 0
		r.closed = true
	}
}

var (
	speedTestPayloadOnce sync.Once
	speedTestPayload     []byte
	speedTestPayloadErr  error
)

func speedTestUploadPayload() ([]byte, error) {
	speedTestPayloadOnce.Do(func() {
		speedTestPayload = make([]byte, 64*1024)
		_, speedTestPayloadErr = rand.Read(speedTestPayload)
	})
	return speedTestPayload, speedTestPayloadErr
}

type speedTestUploadBody struct {
	mu          sync.Mutex
	payload     []byte
	reservation *speedTestReservation
	offset      int
	sent        int64
	closed      bool
}

func (b *speedTestUploadBody) Read(buffer []byte) (int, error) {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.closed || b.sent == b.reservation.amount {
		return 0, io.EOF
	}
	count := int(min(int64(len(buffer)), b.reservation.amount-b.sent))
	for written := 0; written < count; {
		n := copy(buffer[written:count], b.payload[b.offset:])
		written += n
		b.offset = (b.offset + n) % len(b.payload)
	}
	if err := b.reservation.consume(int64(count)); err != nil {
		return 0, err
	}
	b.sent += int64(count)
	return count, nil
}

func (b *speedTestUploadBody) Close() error {
	b.mu.Lock()
	b.closed = true
	b.mu.Unlock()
	return nil
}

func (b *speedTestUploadBody) sentBytes() int64 {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.sent
}
