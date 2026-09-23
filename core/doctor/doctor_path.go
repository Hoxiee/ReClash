package doctor

import "sync/atomic"

var doctorAndroidPathStatus atomic.Value

func init() {
	doctorAndroidPathStatus.Store(doctorPathStatus{PathKind: doctorPathUnknown})
}

func doctorProbeCount(mode doctorExamMode, capabilities doctorCapabilities) int {
	count := 2
	if mode == doctorDeep {
		count++
	}
	if capabilities.AndroidAppIngressProbe {
		count++
	}
	return count
}

func doctorPathContextForStatus(status doctorPathStatus, tunActive bool) doctorPathContext {
	if (status.PathKind == doctorPathVPN || status.PathKind == doctorPathTun) && status.Phase != "active" {
		return doctorPathContext{PathKind: status.PathKind, CaptureState: doctorCaptureInactive}
	}
	return doctorPathContextFor(status.PathKind, tunActive)
}

func doctorPathContextFor(path doctorPathKind, tunActive bool) doctorPathContext {
	switch path {
	case doctorPathVPN, doctorPathTun:
		if tunActive {
			return doctorPathContext{PathKind: path, CaptureState: doctorCaptureActive}
		}
		return doctorPathContext{PathKind: path, CaptureState: doctorCaptureInactive}
	case doctorPathLocalProxy, doctorPathDirect, doctorPathByeDPI:
		return doctorPathContext{PathKind: path, CaptureState: doctorCaptureNotApplicable}
	default:
		return doctorPathContext{PathKind: doctorPathUnknown, CaptureState: doctorCaptureUnknown}
	}
}

func normalizedDoctorPathContext(path doctorPathContext) doctorPathContext {
	if path.PathKind == "" {
		path.PathKind = doctorPathUnknown
	}
	if path.CaptureState == "" {
		path.CaptureState = doctorCaptureUnknown
	}
	return path
}
