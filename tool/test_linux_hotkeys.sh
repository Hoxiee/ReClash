#!/usr/bin/env bash
set -euo pipefail

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
read -r -a gio_flags <<<"$(pkg-config --cflags --libs gio-2.0)"

"${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror \
  -I"$root/linux/runner" \
  "$root/linux/runner/application_actions.cc" \
  "$root/linux/runner/tests/application_actions_test.cc" \
  "${gio_flags[@]}" -o "$build_dir/hotkeys-test"
"$build_dir/hotkeys-test"
