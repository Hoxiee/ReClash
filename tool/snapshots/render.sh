#!/usr/bin/env bash
# Renders the README screenshots from tool/snapshots/mock.dart into
# .dart_tool/snapshots/<shot name>/, then composes them with compose.py.
# Usage: tool/snapshots/render.sh [scale]
set -euo pipefail
cd "$(dirname "$0")/../.."
scale="${1:-2}"
raw=.dart_tool/snapshots
rm -rf "$raw"

shots=(
  'android dashboard plain mobile-dashboard'
  'android dashboard brand mobile-widgets'
  'android profiles plain mobile-profiles'
  'android proxies plain mobile-proxies'
  'android dashboard brand mobile-branded'
  'macos dashboard plain desktop-dashboard'
  'macos profiles plain desktop-profiles'
  'macos dashboard brand desktop-branded'
)

for shot in "${shots[@]}"; do
  read -r platform page brand name <<<"$shot"
  tab=$([[ $name == *-widgets ]] && echo widgets || echo home)
  case "$platform" in
    android) size=412x915 ;;
    *) size=1280x800 ;;
  esac
  out="$raw/$name"
  echo "$out"
  SNAPSHOT_BRAND=$([[ $brand == brand ]] && echo 1 || echo 0) \
    SNAPSHOT_PLATFORM="$platform" SNAPSHOT_PAGE="$page" SNAPSHOT_DASHBOARD=simple SNAPSHOT_TAB="$tab" \
    dart run tool/preview.dart tool/snapshots/app_preview.dart \
    --size "$size" --theme light,dark --scale "$scale" --out "$out"
done

python3 -I tool/snapshots/compose.py "$raw" snapshots
