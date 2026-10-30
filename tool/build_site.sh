#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$#" -ne 0 ]]; then
  echo "usage: tool/build_site.sh (output: site/.output/public)" >&2
  exit 2
fi

if [[ ! -f "$root/site/package.json" ]]; then
  echo "error: initialize the website with git submodule update --init -- site" >&2
  exit 1
fi

node "$root/tool/site_docs.mjs" --check
npm --prefix "$root/site" run build
printf 'site generated in %s/site/.output/public\n' "$root"
