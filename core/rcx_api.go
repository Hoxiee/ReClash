package core

import (
	"errors"

	"core/rcx"
)

type RcxJournalParams struct {
	Cursor uint64 `json:"cursor"`
	Group  string `json:"group,omitempty"`
	Limit  int    `json:"limit,omitempty"`
}

var errRcxNotReady = &MethodError{Code: "rcx_not_ready", Message: "routing engine is not initialized"}

func init() {
	registerMethod(rcxSetPolicyMethod, withFallible(func(layer rcx.UserLayer) (rcx.Status, error) {
		rcxSetUser(layer)
		return rcxCall(func(e *rcx.Engine) (rcx.Status, error) { return e.Status(), nil })
	}))
	registerMethod(rcxStatusMethod, func(*MethodCall) (any, error) {
		return rcxCall(func(e *rcx.Engine) (rcx.Status, error) { return e.Status(), nil })
	})
	registerMethod(rcxExplainMethod, withFallible(func(group string) (rcx.Explanation, error) {
		return rcxCall(func(e *rcx.Engine) (rcx.Explanation, error) { return e.Explain(group) })
	}))
	registerMethod(rcxJournalMethod, withFallible(func(params RcxJournalParams) ([]rcx.JournalEntry, error) {
		return rcxCall(func(e *rcx.Engine) ([]rcx.JournalEntry, error) {
			return e.Journal(params.Cursor, params.Group, params.Limit), nil
		})
	}))
	registerMethod(rcxActionMethod, withFallible(func(req rcx.ActionRequest) (rcx.ActionResult, error) {
		return rcxCall(func(e *rcx.Engine) (rcx.ActionResult, error) { return e.Act(req) })
	}))
	registerMethod(rcxHintsMethod, func(call *MethodCall) (any, error) {
		hints, err := decodeArguments[rcx.Hints](call)
		if err != nil {
			return nil, err
		}
		if hints.Foreground != nil {
			setHostForeground(*hints.Foreground, call.seq)
		}
		return rcxCall(func(e *rcx.Engine) (bool, error) {
			e.SetHints(hints)
			return true, nil
		})
	})
	registerMethod(rcxProfilesMethod, func(*MethodCall) (any, error) {
		return rcxCall(func(e *rcx.Engine) ([]rcx.ProfileInfo, error) { return e.Profiles(), nil })
	})
	registerMethod(rcxStudioMethod, withFallible(func(req rcx.StudioRequest) (rcx.StudioResult, error) {
		return rcxCall(func(e *rcx.Engine) (rcx.StudioResult, error) { return e.Studio(req) })
	}))
}

func rcxCall[R any](run func(e *rcx.Engine) (R, error)) (R, error) {
	e := rcxReady()
	if e == nil {
		var zero R
		return zero, errRcxNotReady
	}
	result, err := run(e)
	if err != nil && !errors.As(err, new(*MethodError)) {
		return result, &MethodError{Code: "rcx_error", Message: err.Error()}
	}
	return result, err
}
