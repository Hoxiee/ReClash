package doctor

// Couplings back to the host (package main) are inverted here: the host binds
// these seams once at construction, so doctor never imports main.

type GoDetached func(name string, run func())

var goDetachedFn GoDetached

func SetGoDetached(fn GoDetached) { goDetachedFn = fn }

func goDetached(name string, run func()) {
	if goDetachedFn != nil {
		goDetachedFn(name, run)
		return
	}
	go run()
}

type Odometer interface {
	NoteExam(healthy bool)
}

type doctorNoopOdometer struct{}

func (doctorNoopOdometer) NoteExam(bool) {}

var doctorOdometer Odometer = doctorNoopOdometer{}

func SetOdometer(o Odometer) {
	if o == nil {
		o = doctorNoopOdometer{}
	}
	doctorOdometer = o
}

var doctorTunActiveFn func() bool

func SetTunActive(fn func() bool) { doctorTunActiveFn = fn }

func doctorTunActive() bool {
	if doctorTunActiveFn != nil {
		return doctorTunActiveFn()
	}
	return false
}
