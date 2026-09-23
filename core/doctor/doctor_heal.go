package doctor

import (
	"context"
	"errors"
	"time"
)

var doctorHealTimeout = 8 * time.Second

var doctorDNSFlushCauses = map[string]struct{}{
	"dnsCacheStale":       {},
	"coreResolverStale":   {},
	"destinationDnsStale": {},
}

func doctorDNSFlushEligible(cause string) bool {
	_, eligible := doctorDNSFlushCauses[cause]
	return eligible
}

func (actor *doctorActor) heal(params doctorHealParams) (doctorSnapshot, error) {
	if params.ActionID != "flushDns" {
		return actor.copySnapshot(), errors.New("unknown_action")
	}
	if params.Revision != actor.snapshot.Revision || params.ExamID == "" || params.ExamID != actor.snapshot.ExamID {
		return actor.copySnapshot(), errors.New("stale_diagnosis")
	}
	if !doctorDNSFlushEligible(actor.snapshot.CauseCode) || actor.snapshot.State == doctorExamining || actor.healInProgress {
		return actor.copySnapshot(), errors.New("action_not_eligible")
	}
	actor.healToken++
	token := actor.healToken
	actor.healInProgress = true
	actor.healExamID = params.ExamID
	mode := actor.snapshot.Mode
	actor.snapshot.HealAudit = appendBounded(actor.snapshot.HealAudit, doctorHealAudit{
		ActionID:       "flushDns",
		At:             actor.now().UnixMilli(),
		Outcome:        "pending",
		BeforeRevision: actor.snapshot.Revision,
	}, doctorMaxIncidents)
	actor.changed()
	goDetached("connection doctor DNS flush", func() {
		completed := make(chan struct{})
		goDetached("connection doctor DNS flush runtime", func() {
			actor.runtime.FlushDNS()
			close(completed)
		})
		select {
		case <-completed:
			actor.sendCommand(context.Background(), doctorCommand{kind: doctorHealCompleteCommand, healToken: token, heal: doctorHealParams{ActionID: string(mode)}})
		case <-time.After(doctorHealTimeout):
			actor.sendCommand(context.Background(), doctorCommand{kind: doctorHealCompleteCommand, healToken: token, token: 1})
		}
	})
	return actor.copySnapshot(), nil
}

func (actor *doctorActor) completeHeal(token uint64, mode doctorExamMode, timedOut bool) {
	if token != actor.healToken || !actor.healInProgress {
		return
	}
	actor.healInProgress = false
	index := len(actor.snapshot.HealAudit) - 1
	if index < 0 || actor.snapshot.HealAudit[index].Outcome != "pending" {
		actor.healExamID = ""
		return
	}
	if timedOut {
		actor.snapshot.HealAudit[index].Outcome = "timeout"
		actor.healExamID = ""
		actor.changed()
		return
	}
	actor.snapshot.HealAudit[index].Outcome = "applied"
	if actor.snapshot.State == doctorExamining || actor.snapshot.ExamID != actor.healExamID || !doctorDNSFlushEligible(actor.snapshot.CauseCode) {
		actor.healExamID = ""
		actor.changed()
		return
	}
	actor.healExamID = ""
	snapshot := actor.start(doctorStartParams{Mode: mode})
	actor.snapshot.HealAudit[index].ReexamID = snapshot.ExamID
	actor.changed()
}
