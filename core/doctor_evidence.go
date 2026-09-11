package main

import (
	"strings"
	"time"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

func doctorEvidenceFromFlow(event tunnel.FlowEvidence) doctorEvidence {
	fact := doctorEvidence{
		Network: event.Network.String(),
		Inbound: doctorInboundCode(event.InboundType),
		at:      event.At,
	}
	switch event.Stage {
	case tunnel.FlowEvidenceIngress:
		fact.Kind = doctorEvidenceIngress
		fact.Layer = doctorLayerIngress
		fact.Outcome = doctorOutcomeSeen
		fact.Confidence = doctorConfirmed
		fact.Code = "inboundAccepted"
	case tunnel.FlowEvidencePreHandleFailed:
		fact.Kind = doctorEvidencePreHandle
		fact.Layer = doctorLayerIngress
		fact.Outcome = doctorOutcomeFailed
		fact.Confidence = doctorConfirmed
		fact.Code = doctorErrorCode("preHandle", event.ErrorClass)
	case tunnel.FlowEvidenceRouteResolved:
		fact.Kind = doctorEvidenceRoute
		fact.Layer = doctorLayerRoute
		fact.Outcome = doctorOutcomeSucceeded
		fact.Confidence = doctorConfirmed
		fact.Code = "routeResolved"
	case tunnel.FlowEvidenceRouteFailed:
		fact.Kind = doctorEvidenceRoute
		fact.Layer = doctorLayerRoute
		fact.Outcome = doctorOutcomeFailed
		fact.Confidence = doctorConfirmed
		fact.Code = doctorErrorCode("route", event.ErrorClass)
		if event.ErrorClass == "dns" {
			fact.Layer = doctorLayerDNS
			fact.Code = "destinationDnsFailed"
		}
	case tunnel.FlowEvidenceDialStarted:
		fact.Kind = doctorEvidenceOuterDial
		fact.Layer = doctorLayerDial
		fact.Outcome = doctorOutcomeSeen
		fact.Confidence = doctorConfirmed
		fact.Code = "outerDialStarted"
	case tunnel.FlowEvidenceDialFinished:
		fact.Kind = doctorEvidenceOuterDial
		fact.Layer = doctorLayerDial
		fact.DurationBucketMs = doctorDurationBucket(event.Duration)
		fact.Confidence = doctorConfirmed
		if event.ErrorClass == "" {
			fact.Outcome = doctorOutcomeSucceeded
			fact.Code = "outerDialSucceeded"
		} else {
			fact.Outcome = doctorOutcomeFailed
			fact.Code = doctorErrorCode("outerDial", event.ErrorClass)
		}
	}
	return fact
}

func doctorEvidenceFromTracker(tracker statistic.Tracker, progress bool) doctorEvidence {
	kind := doctorEvidenceTrackerOpen
	layer := doctorLayerDial
	outcome := doctorOutcomeSeen
	code := "trackerOpened"
	if progress {
		kind = doctorEvidenceFirstProgress
		layer = doctorLayerTransport
		outcome = doctorOutcomeSucceeded
		code = "trafficProgress"
	}
	fact := doctorEvidence{
		Kind:       kind,
		Layer:      layer,
		Outcome:    outcome,
		Confidence: doctorConfirmed,
		Code:       code,
		at:         time.Now(),
	}
	if tracker != nil && tracker.Info() != nil && tracker.Info().Metadata != nil {
		fact.Network = tracker.Info().Metadata.NetWork.String()
		fact.Inbound = doctorInboundCode(tracker.Info().Metadata.Type)
	}
	return fact
}

func doctorInboundCode(inbound C.Type) string {
	switch inbound {
	case C.TUN:
		return "tun"
	case C.HTTP, C.HTTPS:
		return "http"
	case C.SOCKS4, C.SOCKS5:
		return "socks"
	case C.REDIR:
		return "redirect"
	case C.TPROXY:
		return "tproxy"
	case C.INNER:
		return "internal"
	default:
		return "other"
	}
}

func doctorErrorCode(prefix, class string) string {
	if class == "" {
		class = "other"
	}
	return prefix + strings.ToUpper(class[:1]) + class[1:]
}

func doctorDurationBucket(duration time.Duration) int64 {
	milliseconds := duration.Milliseconds()
	for _, ceiling := range []int64{50, 100, 250, 500, 1000, 2000, 5000, 10000, 20000} {
		if milliseconds <= ceiling {
			return ceiling
		}
	}
	return 20000
}

func doctorScopeForEvidence(evidence doctorEvidence) doctorScope {
	if evidence.Inbound == "" || evidence.Inbound == "internal" {
		return doctorScopeApp
	}
	return doctorScopeInbound
}
