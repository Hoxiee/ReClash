#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/.." && pwd)"
cd "$root"

usage() {
  cat <<'EOF'
Usage:
  tool/release.sh prepare <pre|stable> [--version X.Y.Z]
  tool/release.sh tag [--push] [--yes] [--dry-run]

prepare   Bump pubspec.yaml to the next tag, create the notes and summary
          skeletons when missing, and print the commit digest to write them
          from. Commits nothing.
tag       Check that HEAD is a committed prepare of the pubspec version, show
          the release body, and create the tag.

Options:
  --version X.Y.Z    Target app version. Defaults to the pubspec version,
                     bumping the patch when that version is already tagged.
  --push             Push the branch and the tag once the tag exists.
  --yes              Skip the confirmation prompt.
  --dry-run          Run the checks and print the body, change nothing.
  -h, --help         Show this help.

A release is three steps; .agents/skills/release/SKILL.md has the details:
  tool/release.sh prepare pre
  (write release_notes/<tag>.md and release_summaries/<tag>.json, then
   dart run tool/changelog.dart changelog && git commit -m "chore(release): prepare <tag>")
  tool/release.sh tag --push
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

require_clean() {
  if ! git diff --quiet || ! git diff --cached --quiet; then
    die "working tree has uncommitted changes; commit or stash them first"
  fi
}

pubspec_name() {
  sed -n 's/^version: \([^+]*\).*/\1/p' pubspec.yaml
}

prepare() {
  local mode="" want_version=""
  while (($#)); do
    case "$1" in
      pre | stable)
        [[ -z "$mode" ]] || die "mode given twice: $mode and $1"
        mode="$1"
        ;;
      --version)
        (($# > 1)) || die "--version needs a value"
        shift
        want_version="$1"
        ;;
      --version=*) want_version="${1#*=}" ;;
      *) die "unknown prepare argument: $1" ;;
    esac
    shift
  done
  [[ -n "$mode" ]] || die "prepare needs pre or stable"
  if [[ -n "$want_version" && ! "$want_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    die "--version must look like 0.8.97, got: $want_version"
  fi
  require_clean

  local current version
  current="$(pubspec_name)"
  current="${current%%-*}"
  [[ -n "$current" ]] || die "could not read the version from pubspec.yaml"
  if [[ -n "$want_version" ]]; then
    version="$want_version"
  elif git rev-parse -q --verify "refs/tags/v$current" >/dev/null; then
    IFS='.' read -r vmaj vmin vpat <<<"$current"
    version="$vmaj.$vmin.$((vpat + 1))"
  else
    version="$current"
  fi
  git rev-parse -q --verify "refs/tags/v$version" >/dev/null &&
    die "v$version is already tagged; pass --version with the next one"

  local tag
  if [[ "$mode" == "pre" ]]; then
    local last
    last="$(git tag --list "v$version-pre.*" |
      sed -n "s/^v$version-pre\.\([0-9]*\)$/\1/p" | sort -n | tail -1)"
    tag="v$version-pre.$(((${last:-0}) + 1))"
  else
    tag="v$version"
  fi

  sed -i.bak -E "s/^(version: )[^+]+/\1${tag#v}/" pubspec.yaml
  rm -f pubspec.yaml.bak
  tool/bump_version.sh minor >/dev/null

  local notes="release_notes/$tag.md" summary="release_summaries/$tag.json"
  mkdir -p release_notes release_summaries
  if [[ ! -e "$notes" ]]; then
    printf '### New\n\n- \n' >"$notes"
  fi
  if [[ ! -e "$summary" ]]; then
    cat >"$summary" <<EOF
{
  "schemaVersion": 1,
  "tag": "$tag",
  "automaticInstall": false,
  "locales": {
    "en": {
      "headline": "",
      "spotlight": {"title": "", "description": "", "kind": "update"},
      "highlights": [],
      "warnings": []
    },
    "ru": {
      "headline": "",
      "spotlight": {"title": "", "description": "", "kind": "update"},
      "highlights": [],
      "warnings": []
    }
  }
}
EOF
  fi

  dart run tool/changelog.dart digest --tag "$tag"
  cat <<EOF

Prepared $tag: pubspec.yaml is $(sed -n 's/^version: //p' pubspec.yaml).
Next:
  1. Write $notes and $summary from the digest above.
  2. dart run tool/changelog.dart changelog && dart run tool/changelog.dart verify
  3. git add pubspec.yaml CHANGELOG.md $notes $summary
     git commit -m "chore(release): prepare $tag"
  4. tool/release.sh tag --push
To abandon: git checkout -- pubspec.yaml && rm -f $notes $summary (if new).
EOF
}

tag_release() {
  local do_push=0 assume_yes=0 dry_run=0
  while (($#)); do
    case "$1" in
      --push) do_push=1 ;;
      --yes | -y) assume_yes=1 ;;
      --dry-run) dry_run=1 ;;
      *) die "unknown tag argument: $1" ;;
    esac
    shift
  done
  require_clean

  local branch tag
  branch="$(git rev-parse --abbrev-ref HEAD)"
  [[ "$branch" != "HEAD" ]] || die "detached HEAD; check out a branch first"
  tag="v$(pubspec_name)"
  git rev-parse -q --verify "refs/tags/$tag" >/dev/null &&
    die "$tag is already tagged; run tool/release.sh prepare first"

  local file
  for file in "release_notes/$tag.md" "release_summaries/$tag.json"; do
    git cat-file -e "HEAD:$file" 2>/dev/null ||
      die "$file is not committed; run tool/release.sh prepare and commit its files"
  done
  dart run tool/check_release_version.dart "$tag" >/dev/null
  dart run tool/changelog.dart verify
  echo "--- full test suite ---"
  dart run tool/test.dart --summary-only ||
    die "the full suite fails; a tag would only publish a red release run"

  echo "--- release body for $tag ---"
  dart run tool/changelog.dart render release --tag "$tag" |
    sed -n '/changelog:begin/,/changelog:end/p' | sed '1d;$d'
  echo "--- end of body ---"
  echo "branch: $branch at $(git rev-parse --short HEAD)"

  if ((dry_run)); then
    echo "dry run: nothing was changed."
    return 0
  fi
  if ((assume_yes == 0)); then
    [[ -r /dev/tty ]] || die "no terminal to confirm on; pass --yes to run unattended"
    local reply
    read -r -p "Tag $tag? [y/n] " reply </dev/tty ||
      die "no answer read; pass --yes to run unattended"
    [[ "$reply" =~ ^[yY]([eE][sS])?$ ]] || {
      echo "Cancelled. Nothing was changed."
      return 0
    }
  fi

  git tag "$tag"
  echo "tagged $tag at $(git rev-parse --short HEAD)"
  # Release tags are lightweight, and --follow-tags skips those silently.
  if ((do_push)); then
    git push origin "$branch"
    git push origin "$tag"
    echo "pushed $branch and $tag"
  else
    echo "Nothing was pushed. To publish:"
    echo "  git push origin $branch && git push origin $tag"
  fi
}

case "${1:-}" in
  prepare)
    shift
    prepare "$@"
    ;;
  tag)
    shift
    tag_release "$@"
    ;;
  -h | --help)
    usage
    ;;
  *)
    usage >&2
    exit 64
    ;;
esac
