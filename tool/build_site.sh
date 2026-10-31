#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
site="$root/../reclash-site"

if [[ "$#" -ne 0 ]]; then
  echo "usage: tool/build_site.sh (output: ../reclash-site/.output/public)" >&2
  exit 2
fi

if [[ ! -f "$site/package.json" ]]; then
  echo "error: clone Hoxiee/reclash-site beside ReClash at ../reclash-site" >&2
  exit 1
fi

node "$root/tool/site_docs.mjs" --check
npm --prefix "$site" run build
printf 'site generated in %s/.output/public\n' "$site"
