package rcx

import (
	"errors"
	"fmt"
	"maps"
	"slices"
	"strconv"
	"strings"
)

// CondForm is a condition as the builder shows it: clauses joined by one
// operator. Flat is false when the text nests deeper than that; the builder
// then leaves it to the text field.
type CondForm struct {
	Join    string   `json:"join"`
	Clauses []Clause `json:"clauses"`
	Flat    bool     `json:"flat"`
	Error   string   `json:"error,omitempty"`
}

// Clause is one predicate: a field with its operator and values, or
// tag/passes/fails/diag with the name in Values.
type Clause struct {
	Not        bool     `json:"not,omitempty"`
	Field      string   `json:"field"`
	Op         string   `json:"op,omitempty"`
	Values     []string `json:"values,omitempty"`
	IgnoreCase bool     `json:"ignoreCase,omitempty"`
}

// FieldInfo is one entry of the builder's field picker.
type FieldInfo struct {
	Name    string   `json:"name"`
	Kind    string   `json:"kind"`
	Network bool     `json:"network,omitempty"`
	Ops     []string `json:"ops,omitempty"`
	Values  []string `json:"values,omitempty"`
}

var (
	stringOps  = []string{"=", "!=", "in", "~"}
	numberOps  = []string{"=", "!=", "<", "<=", ">", ">="}
	countryOps = []string{"=", "!=", "in"}
	keywords   = map[string]bool{"and": true, "or": true, "not": true, "in": true, "ok": true, "fail": true}
)

func studioCond(req StudioRequest) (StudioResult, error) {
	scope, fields := builderScope(req.Profile, req.Scenario, req.Network)
	out := StudioResult{Fields: fields}
	text := req.Text
	if req.Form != nil {
		var err error
		if text, err = formText(*req.Form); err != nil {
			out.Form = &CondForm{Join: req.Form.Join, Clauses: req.Form.Clauses, Flat: true, Error: err.Error()}
			return out, nil
		}
	}
	out.Text = text
	cond, err := parseCond(text, scope)
	switch {
	case err != nil:
		out.Form = &CondForm{Join: "and", Error: err.Error()}
		if req.Form != nil {
			out.Form.Clauses, out.Form.Flat = req.Form.Clauses, true
		}
	case cond == nil:
		out.Form = &CondForm{Join: "and", Flat: true}
	default:
		form := formOf(cond.root)
		out.Form = &form
	}
	return out, nil
}

// builderScope: a condition inside a scenario sees the scenario's tags and
// diagnostics beside those of the profile its program names.
func builderScope(profile *Profile, scenario *Scenario, network bool) (condScope, []FieldInfo) {
	if profile == nil {
		profile = &Profile{}
	}
	if scenario == nil {
		scenario = &Scenario{}
	}
	scope := condScope{tags: map[string]bool{}, checks: map[string]bool{}}
	for _, name := range slices.Concat(slices.Collect(maps.Keys(profile.Tags)), slices.Collect(maps.Keys(scenario.Tags))) {
		scope.tags[name] = true
	}
	for id := range profile.Checks {
		scope.checks[id] = true
	}
	var fields []FieldInfo
	for _, name := range slices.Sorted(maps.Keys(condFields)) {
		spec := condFields[name]
		if network && spec.scope != netField {
			continue
		}
		field := FieldInfo{Name: name, Network: spec.scope == netField}
		switch spec.kind {
		case stringField:
			field.Kind, field.Ops = "string", stringOps
		case countryField:
			field.Kind, field.Ops = "country", countryOps
		case numberField:
			field.Kind, field.Ops = "number", numberOps
		default:
			field.Kind = "bool"
		}
		fields = append(fields, field)
	}
	if network {
		scope = condScope{diags: map[string]bool{}}
		for _, name := range slices.Concat(slices.Collect(maps.Keys(profile.Network.Diagnose)), slices.Collect(maps.Keys(scenario.Network.Diagnose))) {
			scope.diags[name] = true
		}
		return scope, append(fields, FieldInfo{Name: "diag", Kind: "diag", Network: true, Ops: []string{"ok", "fail"}, Values: slices.Sorted(maps.Keys(scope.diags))})
	}
	return scope, append(fields,
		FieldInfo{Name: "tag", Kind: "tag", Values: slices.Sorted(maps.Keys(scope.tags))},
		FieldInfo{Name: "passes", Kind: "check", Values: slices.Sorted(maps.Keys(scope.checks))},
		FieldInfo{Name: "fails", Kind: "check", Values: slices.Sorted(maps.Keys(scope.checks))},
	)
}

func formOf(root condNode) CondForm {
	items, join := []condNode{root}, "and"
	switch n := root.(type) {
	case andNode:
		items = n.items
	case orNode:
		items, join = n.items, "or"
	}
	form := CondForm{Join: join, Flat: true}
	for _, item := range items {
		clause, ok := clauseOf(item)
		if !ok {
			return CondForm{Join: join}
		}
		form.Clauses = append(form.Clauses, clause)
	}
	return form
}

func clauseOf(n condNode) (Clause, bool) {
	not := false
	if inner, ok := n.(notNode); ok {
		n, not = inner.item, true
	}
	switch n := n.(type) {
	case boolNode:
		return Clause{Not: not, Field: n.field}, true
	case tagNode:
		return Clause{Not: not, Field: "tag", Values: []string{n.tag}}, true
	case checkNode:
		field := "fails"
		if n.pass {
			field = "passes"
		}
		return Clause{Not: not, Field: field, Values: []string{n.check}}, true
	case diagNode:
		op := "fail"
		if n.ok {
			op = "ok"
		}
		return Clause{Not: not, Field: "diag", Op: op, Values: []string{n.diag}}, true
	case numberNode:
		return Clause{Not: not, Field: "latency", Op: n.op, Values: []string{strconv.Itoa(n.value)}}, true
	case stringNode:
		clause := Clause{Not: not, Field: n.field, Op: n.op, Values: n.values}
		if n.re != nil {
			pattern, fold := strings.CutPrefix(n.re.String(), "(?i)")
			clause.Values, clause.IgnoreCase = []string{pattern}, fold
		}
		return clause, true
	}
	return Clause{}, false
}

func formText(form CondForm) (string, error) {
	if form.Join != "and" && form.Join != "or" && len(form.Clauses) > 1 {
		return "", fmt.Errorf("join %q is not and or or", form.Join)
	}
	parts := make([]string, 0, len(form.Clauses))
	for _, clause := range form.Clauses {
		text, err := clauseText(clause)
		if err != nil {
			return "", err
		}
		if clause.Not {
			text = "not " + text
		}
		parts = append(parts, text)
	}
	return strings.Join(parts, " "+form.Join+" "), nil
}

func clauseText(c Clause) (string, error) {
	first := ""
	if len(c.Values) > 0 {
		first = c.Values[0]
	}
	switch c.Field {
	case "tag", "passes", "fails":
		value, err := quoteValue(first)
		return c.Field + "(" + value + ")", err
	case "diag":
		return first + " " + c.Op, nil
	}
	spec, known := condFields[c.Field]
	switch {
	case !known:
		return "", fmt.Errorf("unknown field %q", c.Field)
	case spec.kind == boolField:
		return c.Field, nil
	case spec.kind == numberField:
		return c.Field + " " + c.Op + " " + first, nil
	case c.Op == "~":
		pattern := "/" + strings.ReplaceAll(first, "/", `\/`) + "/"
		if c.IgnoreCase {
			pattern += "i"
		}
		return c.Field + " ~ " + pattern, nil
	case c.Op == "in":
		values := make([]string, len(c.Values))
		for i, v := range c.Values {
			quoted, err := quoteValue(v)
			if err != nil {
				return "", err
			}
			values[i] = quoted
		}
		return c.Field + " in [" + strings.Join(values, ", ") + "]", nil
	}
	value, err := quoteValue(first)
	return c.Field + " " + c.Op + " " + value, err
}

func quoteValue(v string) (string, error) {
	plain := v != "" && !keywords[strings.ToLower(v)]
	for _, r := range v {
		plain = plain && isWordRune(r)
	}
	switch {
	case plain:
		return v, nil
	case !strings.Contains(v, "'"):
		return "'" + v + "'", nil
	case !strings.Contains(v, `"`):
		return `"` + v + `"`, nil
	}
	return "", errors.New("a value cannot hold both kinds of quotes")
}
