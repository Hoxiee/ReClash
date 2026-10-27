#!/usr/bin/env bash
# Renders the README screenshots from tool/snapshots/mock.dart into
# .dart_tool/snapshots/<platform>-<page>/, then composes them with compose.py.
# Usage: tool/snapshots/render.sh [scale]
set -euo pipefail
cd "$(dirname "$0")/../.."
scale="${1:-2}"
raw=.dart_tool/snapshots

shots=(
  'macos dashboard detailed'
  'macos proxies detailed'
  'macos profiles detailed'
  'macos connections detailed'
  'android dashboard simple'
  'android proxies simple'
  'android profiles simple'
)

for shot in "${shots[@]}"; do
  read -r platform page dashboard <<<"$shot"
  case "$platform" in
    android) size=412x915 ;;
    *) size=1280x800 ;;
  esac
  out="$raw/$platform-$page-$dashboard"
  echo "$out"
  SNAPSHOT_PLATFORM="$platform" SNAPSHOT_PAGE="$page" SNAPSHOT_DASHBOARD="$dashboard" \
    dart run tool/preview.dart tool/snapshots/app_preview.dart \
    --size "$size" --theme light,dark --scale "$scale" --out "$out"
done

python3 -I tool/snapshots/compose.py "$raw" snapshots
