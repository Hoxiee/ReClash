package rcx

import (
	"fmt"
	"regexp"
	"slices"
	"strconv"
	"strings"
	"unicode"
)

const (
	maxConditionLength = 2048
	maxConditionDepth  = 16
	maxPatternLength   = 512
)

// Subject is what a condition reads about one candidate. Empty strings and
// missing checks are unknown, not false.
type Subject struct {
	Name     string
	Provider string
	Type     string
	Server   string
	UDP      bool
	Alive    bool
	Dead     bool
	Measured bool
	Current  bool
	Latency  int
	Tags     map[string]bool
	Exit     string
	Entry    string
	Checks   map[string]tri
	Net      *NetSubject
}

// NetSubject is what a network condition reads: the network itself and the
// outcome of each direct diagnostic.
type NetSubject struct {
	Kind      string
	Transport string
	Portal    bool
	Metered   bool
	Diag      map[string]tri
}

// tri is Kleene logic: a condition over a fact nobody measured yet is
// unknown, which the planner reads as "worth a check".
type tri int8

const (
	triNo tri = iota
	triYes
	triUnknown
	// triNeither is a soft check failure: neither passes() nor fails().
	triNeither
)

func triOf(b bool) tri {
	if b {
		return triYes
	}
	return triNo
}

// Cond is a compiled condition. The text it came from is kept for errors and
// explanations, so the UI shows what the author wrote.
type Cond struct {
	Text string
	root condNode
}

func (c *Cond) Eval(s *Subject) bool { return c.Test(s) == triYes }

func (c *Cond) Test(s *Subject) tri {
	if c == nil || c.root == nil {
		return triYes
	}
	return c.root.eval(s)
}

type condNode interface {
	eval(s *Subject) tri
}

func (c *Cond) walk(visit func(condNode)) {
	if c == nil {
		return
	}
	var walk func(n condNode)
	walk = func(n condNode) {
		visit(n)
		switch n := n.(type) {
		case andNode:
			for _, item := range n.items {
				walk(item)
			}
		case orNode:
			for _, item := range n.items {
				walk(item)
			}
		case notNode:
			walk(n.item)
		}
	}
	walk(c.root)
}

type fieldKind int

const (
	stringField fieldKind = iota
	boolField
	numberField
)

type fieldScope int

const (
	nodeField fieldScope = iota
	netField
)

var condFields = map[string]struct {
	kind  fieldKind
	scope fieldScope
}{
	"name":              {stringField, nodeField},
	"provider":          {stringField, nodeField},
	"type":              {stringField, nodeField},
	"server":            {stringField, nodeField},
	"exit.country":      {stringField, nodeField},
	"entry.country":     {stringField, nodeField},
	"udp":               {boolField, nodeField},
	"alive":             {boolField, nodeField},
	"dead":              {boolField, nodeField},
	"measured":          {boolField, nodeField},
	"current":           {boolField, nodeField},
	"latency":           {numberField, nodeField},
	"network.kind":      {stringField, netField},
	"network.transport": {stringField, netField},
	"network.portal":    {boolField, netField},
	"metered":           {boolField, netField},
}

func stringOf(s *Subject, field string) (string, bool) {
	switch field {
	case "name":
		return s.Name, true
	case "provider":
		return s.Provider, true
	case "type":
		return s.Type, true
	case "server":
		return s.Server, true
	case "exit.country":
		return s.Exit, s.Exit != ""
	case "entry.country":
		return s.Entry, s.Entry != ""
	}
	if s.Net == nil {
		return "", false
	}
	if field == "network.kind" {
		return s.Net.Kind, s.Net.Kind != ""
	}
	return s.Net.Transport, s.Net.Transport != ""
}

func boolOf(s *Subject, field string) tri {
	switch field {
	case "udp":
		return triOf(s.UDP)
	case "alive":
		return triOf(s.Alive)
	case "dead":
		return triOf(s.Dead)
	case "measured":
		return triOf(s.Measured)
	case "current":
		return triOf(s.Current)
	}
	if s.Net == nil {
		return triUnknown
	}
	if field == "metered" {
		return triOf(s.Net.Metered)
	}
	return triOf(s.Net.Portal)
}

type andNode struct{ items []condNode }
type orNode struct{ items []condNode }
type notNode struct{ item condNode }
type boolNode struct{ field string }
type tagNode struct{ tag string }

// checkNode is passes(x) or fails(x); diagNode is "<diagnostic> ok|fail".
type checkNode struct {
	check string
	pass  bool
}

type diagNode struct {
	diag string
	ok   bool
}

type stringNode struct {
	field  string
	op     string
	values []string
	re     *regexp.Regexp
}

type numberNode struct {
	op    string
	value int
}

func (n andNode) eval(s *Subject) tri {
	out := triYes
	for _, item := range n.items {
		switch item.eval(s) {
		case triNo:
			return triNo
		case triUnknown:
			out = triUnknown
		}
	}
	return out
}

func (n orNode) eval(s *Subject) tri {
	out := triNo
	for _, item := range n.items {
		switch item.eval(s) {
		case triYes:
			return triYes
		case triUnknown:
			out = triUnknown
		}
	}
	return out
}

func (n notNode) eval(s *Subject) tri {
	switch v := n.item.eval(s); v {
	case triUnknown:
		return v
	default:
		return triOf(v == triNo)
	}
}

func (n boolNode) eval(s *Subject) tri { return boolOf(s, n.field) }
func (n tagNode) eval(s *Subject) tri  { return triOf(s.Tags[n.tag]) }

func (n checkNode) eval(s *Subject) tri {
	switch v, ok := s.Checks[n.check]; {
	case !ok || v == triUnknown:
		return triUnknown
	case v == triNeither:
		return triNo
	default:
		return triOf((v == triYes) == n.pass)
	}
}

func (n diagNode) eval(s *Subject) tri {
	if s.Net == nil {
		return triUnknown
	}
	v, ok := s.Net.Diag[n.diag]
	if !ok || v == triUnknown {
		return triUnknown
	}
	return triOf((v == triYes) == n.ok)
}

func (n stringNode) eval(s *Subject) tri {
	value, known := stringOf(s, n.field)
	if !known {
		return triUnknown
	}
	switch n.op {
	case "~":
		return triOf(n.re.MatchString(value))
	case "!=":
		return triOf(!strings.EqualFold(value, n.values[0]))
	case "in":
		return triOf(slices.ContainsFunc(n.values, func(v string) bool { return strings.EqualFold(v, value) }))
	default:
		return triOf(strings.EqualFold(value, n.values[0]))
	}
}

// An unmeasured node has no latency, so no latency bound holds for it.
func (n numberNode) eval(s *Subject) tri {
	if !s.Measured {
		return triNo
	}
	switch n.op {
	case "<":
		return triOf(s.Latency < n.value)
	case "<=":
		return triOf(s.Latency <= n.value)
	case ">":
		return triOf(s.Latency > n.value)
	case ">=":
		return triOf(s.Latency >= n.value)
	case "!=":
		return triOf(s.Latency != n.value)
	default:
		return triOf(s.Latency == n.value)
	}
}

// condScope names what a condition may reference. Nil tags forbid tag(),
// which keeps tag definitions from referring to each other; non-nil diags
// make it a network condition, which reads no node.
type condScope struct {
	tags   map[string]bool
	checks map[string]bool
	diags  map[string]bool
}

// ParseCond compiles a node condition that may reference the given tags.
func ParseCond(text string, tags map[string]bool) (*Cond, error) {
	return parseCond(text, condScope{tags: tags})
}

func parseCond(text string, scope condScope) (*Cond, error) {
	text = strings.TrimSpace(text)
	if text == "" {
		return nil, nil
	}
	if len(text) > maxConditionLength {
		return nil, fmt.Errorf("condition longer than %d characters", maxConditionLength)
	}
	tokens, err := lexCond(text)
	if err != nil {
		return nil, err
	}
	p := &condParser{tokens: tokens, scope: scope}
	root, err := p.or(0)
	if err != nil {
		return nil, err
	}
	if !p.done() {
		return nil, fmt.Errorf("unexpected %q", p.peek().text)
	}
	return &Cond{Text: text, root: root}, nil
}

type tokenKind int

const (
	wordToken tokenKind = iota
	stringToken
	regexToken
	opToken
	punctToken
)

type condToken struct {
	kind tokenKind
	text string
}

func lexCond(text string) ([]condToken, error) {
	var tokens []condToken
	runes := []rune(text)
	for i := 0; i < len(runes); {
		r := runes[i]
		switch {
		case unicode.IsSpace(r):
			i++
		case r == '(' || r == ')' || r == '[' || r == ']' || r == ',':
			tokens = append(tokens, condToken{punctToken, string(r)})
			i++
		case r == '=' || r == '~':
			tokens = append(tokens, condToken{opToken, string(r)})
			i++
		case r == '!' || r == '<' || r == '>':
			op := string(r)
			if i+1 < len(runes) && runes[i+1] == '=' {
				op += "="
				i++
			}
			if op == "!" {
				return nil, fmt.Errorf("use 'not' instead of '!'")
			}
			tokens = append(tokens, condToken{opToken, op})
			i++
		case r == '\'' || r == '"':
			end := i + 1
			for end < len(runes) && runes[end] != r {
				end++
			}
			if end == len(runes) {
				return nil, fmt.Errorf("unterminated string")
			}
			tokens = append(tokens, condToken{stringToken, string(runes[i+1 : end])})
			i = end + 1
		case r == '/':
			var pattern strings.Builder
			end := i + 1
			for ; end < len(runes) && runes[end] != '/'; end++ {
				if runes[end] == '\\' && end+1 < len(runes) && runes[end+1] == '/' {
					end++
				}
				pattern.WriteRune(runes[end])
			}
			if end == len(runes) {
				return nil, fmt.Errorf("unterminated pattern")
			}
			end++
			flags := ""
			for end < len(runes) && unicode.IsLetter(runes[end]) {
				flags += string(runes[end])
				end++
			}
			if flags != "" && flags != "i" {
				return nil, fmt.Errorf("unsupported pattern flags %q", flags)
			}
			if flags == "i" {
				tokens = append(tokens, condToken{regexToken, "(?i)" + pattern.String()})
			} else {
				tokens = append(tokens, condToken{regexToken, pattern.String()})
			}
			i = end
		case isWordRune(r):
			end := i
			for end < len(runes) && isWordRune(runes[end]) {
				end++
			}
			tokens = append(tokens, condToken{wordToken, string(runes[i:end])})
			i = end
		default:
			return nil, fmt.Errorf("unexpected character %q", r)
		}
	}
	return tokens, nil
}

func isWordRune(r rune) bool {
	return unicode.IsLetter(r) || unicode.IsDigit(r) || r == '_' || r == '-' || r == '.' || r == ':'
}

type condParser struct {
	tokens []condToken
	pos    int
	scope  condScope
}

func (p *condParser) done() bool { return p.pos >= len(p.tokens) }

func (p *condParser) peek() condToken {
	if p.done() {
		return condToken{punctToken, "end"}
	}
	return p.tokens[p.pos]
}

func (p *condParser) next() condToken {
	token := p.peek()
	p.pos++
	return token
}

func (p *condParser) keyword(word string) bool {
	token := p.peek()
	if token.kind == wordToken && strings.EqualFold(token.text, word) {
		p.pos++
		return true
	}
	return false
}

func (p *condParser) expect(text string) error {
	if token := p.next(); token.text != text || token.kind == stringToken {
		return fmt.Errorf("expected %q, found %q", text, token.text)
	}
	return nil
}

func (p *condParser) or(depth int) (condNode, error) {
	if depth > maxConditionDepth {
		return nil, fmt.Errorf("condition nested deeper than %d", maxConditionDepth)
	}
	first, err := p.and(depth)
	if err != nil {
		return nil, err
	}
	items := []condNode{first}
	for p.keyword("or") {
		item, err := p.and(depth)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	if len(items) == 1 {
		return first, nil
	}
	return orNode{items}, nil
}

func (p *condParser) and(depth int) (condNode, error) {
	first, err := p.unary(depth)
	if err != nil {
		return nil, err
	}
	items := []condNode{first}
	for p.keyword("and") {
		item, err := p.unary(depth)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	if len(items) == 1 {
		return first, nil
	}
	return andNode{items}, nil
}

func (p *condParser) unary(depth int) (condNode, error) {
	if p.keyword("not") {
		item, err := p.unary(depth + 1)
		if err != nil {
			return nil, err
		}
		return notNode{item}, nil
	}
	if p.peek().kind == punctToken && p.peek().text == "(" {
		p.pos++
		item, err := p.or(depth + 1)
		if err != nil {
			return nil, err
		}
		return item, p.expect(")")
	}
	return p.predicate()
}

func (p *condParser) predicate() (condNode, error) {
	token := p.next()
	if token.kind != wordToken {
		return nil, fmt.Errorf("expected a field, found %q", token.text)
	}
	field := strings.ToLower(token.text)
	network := p.scope.diags != nil
	switch {
	case field == "tag" || field == "passes" || field == "fails":
		name, err := p.call()
		if err != nil {
			return nil, err
		}
		if field == "tag" {
			if p.scope.tags == nil || network {
				return nil, fmt.Errorf("tag(%s) is not allowed here", name)
			}
			if !p.scope.tags[name] {
				return nil, fmt.Errorf("unknown tag %q", name)
			}
			return tagNode{name}, nil
		}
		if !p.scope.checks[name] || network {
			return nil, fmt.Errorf("unknown check %q", name)
		}
		return checkNode{check: name, pass: field == "passes"}, nil
	case p.scope.diags[token.text]:
		switch state := p.next(); {
		case state.kind == wordToken && strings.EqualFold(state.text, "ok"):
			return diagNode{diag: token.text, ok: true}, nil
		case state.kind == wordToken && strings.EqualFold(state.text, "fail"):
			return diagNode{diag: token.text}, nil
		default:
			return nil, fmt.Errorf("%s needs ok or fail, found %q", token.text, state.text)
		}
	}
	spec, known := condFields[field]
	if !known {
		return nil, fmt.Errorf("unknown field %q", token.text)
	}
	if network && spec.scope != netField {
		return nil, fmt.Errorf("%s is about a server, not the network", field)
	}
	if spec.kind == boolField {
		return boolNode{field}, nil
	}
	op := p.next()
	if op.kind != opToken && !(op.kind == wordToken && strings.EqualFold(op.text, "in")) {
		return nil, fmt.Errorf("%s needs an operator, found %q", field, op.text)
	}
	operator := strings.ToLower(op.text)
	if spec.kind == numberField {
		return p.number(field, operator)
	}
	return p.text(field, operator)
}

func (p *condParser) call() (string, error) {
	if err := p.expect("("); err != nil {
		return "", err
	}
	name := p.next()
	if name.kind != wordToken && name.kind != stringToken {
		return "", fmt.Errorf("expected a name, found %q", name.text)
	}
	return name.text, p.expect(")")
}

func (p *condParser) number(field, op string) (condNode, error) {
	switch op {
	case "=", "!=", "<", "<=", ">", ">=":
	default:
		return nil, fmt.Errorf("%s does not take %q", field, op)
	}
	token := p.next()
	value, err := strconv.Atoi(strings.TrimSuffix(token.text, "ms"))
	if err != nil || token.kind != wordToken {
		return nil, fmt.Errorf("%s needs a number, found %q", field, token.text)
	}
	return numberNode{op: op, value: value}, nil
}

func (p *condParser) text(field, op string) (condNode, error) {
	switch op {
	case "~":
		token := p.next()
		if token.kind != regexToken && token.kind != stringToken {
			return nil, fmt.Errorf("~ needs a /pattern/, found %q", token.text)
		}
		if len(token.text) > maxPatternLength {
			return nil, fmt.Errorf("pattern longer than %d characters", maxPatternLength)
		}
		re, err := regexp.Compile(token.text)
		if err != nil {
			return nil, fmt.Errorf("pattern: %v", err)
		}
		return stringNode{field: field, op: op, re: re}, nil
	case "in":
		if err := p.expect("["); err != nil {
			return nil, err
		}
		var values []string
		for {
			value, err := p.value()
			if err != nil {
				return nil, err
			}
			values = append(values, value)
			if p.peek().text == "]" && p.peek().kind == punctToken {
				p.pos++
				return stringNode{field: field, op: op, values: values}, nil
			}
			if err := p.expect(","); err != nil {
				return nil, err
			}
		}
	case "=", "!=":
		value, err := p.value()
		if err != nil {
			return nil, err
		}
		return stringNode{field: field, op: op, values: []string{value}}, nil
	default:
		return nil, fmt.Errorf("%s does not take %q", field, op)
	}
}

func (p *condParser) value() (string, error) {
	token := p.next()
	if token.kind != wordToken && token.kind != stringToken {
		return "", fmt.Errorf("expected a value, found %q", token.text)
	}
	return token.text, nil
}
