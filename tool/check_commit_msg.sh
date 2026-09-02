#!/usr/bin/env bash

set -euo pipefail

message_file="${1:?commit message file is required}"

# The subject and the body have to be cut from the same text, or they overlap:
# `git commit --cleanup=verbatim` and hook-written templates both leave blank
# lines above the subject, and a body taken as "everything from line two" then
# contains the subject itself — enough for the trailer checks below to read the
# subject as a footer.
cleaned="$(grep -v '^#' "$message_file" | sed '/[^[:space:]]/,$!d' || true)"

subject="$(head -n 1 <<<"$cleaned")"

if [[ -z "$subject" ]]; then
  echo 'Commit message is empty.' >&2
  exit 1
fi

if [[ "$subject" =~ ^(Merge|Revert)[[:space:]] ]]; then
  exit 0
fi

if [[ "$subject" =~ ^(fixup|squash)! ]]; then
  exit 0
fi

types='feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert'

if [[ ! "$subject" =~ ^($types)(\([a-z0-9,./_-]+\))?!?:[[:space:]].+ ]]; then
  cat >&2 <<EOF
Commit subject does not follow Conventional Commits:

  $subject

Expected: <type>[(scope)][!]: <description>
Types:    ${types//|/, }
Examples:
  perf(views): stop redoing per-frame work in build
  refactor(tray): replace the tray_manager fork with a first-party plugin
  fix(core,android)!: keep failures visible and lifecycle results honest
EOF
  exit 1
fi

if [[ ${#subject} -gt 100 ]]; then
  echo "Commit subject is ${#subject} characters; keep it within 100." >&2
  exit 1
fi

description="${subject#*: }"

first_word="${description%% *}"
first_word="${first_word%%[^[:alnum:]]*}"

if [[ "$first_word" =~ ^[A-Z][a-z]+$ ]]; then
  echo "Commit description should start in lower case: $description" >&2
  echo 'Identifiers and acronyms keep their own casing, for example AppBar or DNS.' >&2
  exit 1
fi

if [[ "$description" =~ \.$ ]]; then
  echo "Commit description should not end with a period: $description" >&2
  exit 1
fi

# Changelog trailers. `tool/changelog.dart` reads these to build the user facing
# changelog; the subject is only a fallback.
body="$(tail -n +2 <<<"$cleaned")"
groups='breaking|feat|fix|perf|revert'

while IFS= read -r line; do
  if [[ "$line" =~ ^Changelog-([A-Za-z0-9-]+): ]]; then
    key="${BASH_REMATCH[1]}"
    if [[ "$key" != 'Type' ]]; then
      echo "Unknown changelog trailer: Changelog-$key" >&2
      echo "The changelog is English only; Changelog-Type is the only" >&2
      echo "suffixed trailer. Do not add translations to commit messages." >&2
      exit 1
    fi
    value="${line#*: }"
    if [[ ! "$value" =~ ^($groups)$ ]]; then
      echo "Unknown Changelog-Type: $value" >&2
      echo "Expected one of: ${groups//|/, }" >&2
      exit 1
    fi
  fi
  if [[ "$line" =~ ^Breaking-([A-Za-z0-9-]+): ]]; then
    echo "Unknown breaking trailer: Breaking-${BASH_REMATCH[1]}" >&2
    echo "The changelog is English only; use BREAKING CHANGE: alone." >&2
    exit 1
  fi
done <<<"$body"

# The body is only for what neither the subject nor the diff can say: a
# constraint, an upstream behavior being worked around, a user-visible effect.
# Lines the changelog reads as trailers are exempt, as are blank lines.
# Each line is capped in words and the whole body in lines, so a big change
# may carry a few terse bullets while a small one needs none.
prose="$(grep -vE '^(Changelog|Changelog-Type|Changelog-|Breaking-|BREAKING[ -]CHANGE|Co-[Aa]uthored-[Bb]y)' <<<"$body" |
  grep -vE '^[[:space:]]*$' || true)"
max_body_words="${COMMIT_BODY_MAX_WORDS:-10}"
max_body_lines="${COMMIT_BODY_MAX_LINES:-8}"

# "<line number>:<word count>" of the first line over the word cap.
overlong_line="$(awk -v max="$max_body_words" '
  { sub(/^[[:space:]]*[-*+][[:space:]]+/, ""); sub(/^[[:space:]]+/, "")
    if (NF > max) { print NR ":" NF; exit } }' <<<"$prose")"
prose_lines="$(grep -c . <<<"$prose" || true)"

if [[ -n "$overlong_line" ]]; then
  line_no="${overlong_line%%:*}"
  line_words="${overlong_line##*:}"
  cat >&2 <<EOF
Commit body line ${line_no} is ${line_words} words; keep every line at or under ${max_body_words}.

A body line is a terse bullet carrying one fact the subject and the diff
cannot show — a constraint, an upstream behavior being worked around, a
user-visible effect. It is not a sentence, a plan, or an essay. A small
change needs no body at all.

A rare change that genuinely needs more raises the caps for that commit:
  COMMIT_BODY_MAX_WORDS=${line_words} git commit
EOF
  exit 1
fi

if (( prose_lines > max_body_lines )); then
  cat >&2 <<EOF
Commit body is ${prose_lines} lines; keep it at or under ${max_body_lines}.

Each line is already a terse bullet, so a body this size reads as a summary
of the diff. Keep only the few facts the subject and the diff cannot show;
a small change needs no body at all.

A rare change that genuinely needs more raises the caps for that commit:
  COMMIT_BODY_MAX_LINES=${prose_lines} git commit
EOF
  exit 1
fi

agents='anthropic|claude|codex|copilot|cursor|devin|gemini|openai|\[bot\]'

if grep -qiE "^Co-authored-by:.*($agents)" <<<"$body"; then
  cat >&2 <<'EOF'
Do not credit a coding agent in a Co-authored-by trailer.

The history records who owns the change, not which tool typed it. Human
co-authors are still fine.
EOF
  exit 1
fi

if [[ "$subject" =~ ^($types)(\([a-z0-9,./_-]+\))?!: ]] &&
  ! grep -qE '^BREAKING[ -]CHANGE:' <<<"$body"; then
  cat >&2 <<'EOF'
A breaking commit needs a BREAKING CHANGE footer describing what breaks:

  feat(backup)!: new archive layout

  BREAKING CHANGE: Archives from 0.8.95 and earlier need re-import
EOF
  exit 1
fi

type="${subject%%[(:!]*}"

if [[ "$type" =~ ^(feat|fix|perf)$ ]] && ! grep -qE '^Changelog:' <<<"$body"; then
  cat >&2 <<EOF
Note: no "Changelog:" trailer, so the changelog will reuse this subject.

  Changelog: $description
EOF
fi
