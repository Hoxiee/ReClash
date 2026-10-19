#!/bin/bash
set -euo pipefail
if [[ $# != 1 || "$1" != *.app || ! -d "$1" ]]; then
    echo 'Usage: verify_bundle.sh /path/to/ReClash.app' >&2
    exit 2
fi
bundle="$1"
app_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$bundle/Contents/Info.plist")"
helper_id="$app_id.helper"
core="$bundle/Contents/MacOS/ReClashCore"
helper="$bundle/Contents/Library/LaunchServices/$helper_id"
manifest="$bundle/Contents/MacOS/manifest.json"
plist="$bundle/Contents/Library/LaunchDaemons/$helper_id.plist"
for binary in "$bundle" "$core" "$helper"; do
    /usr/bin/codesign --verify --strict --all-architectures "$binary"
done
team="$(/usr/bin/codesign -dv --verbose=4 "$bundle" 2>&1 | /usr/bin/sed -n 's/^TeamIdentifier=//p')"
[[ "$team" =~ ^[A-Z0-9]{10}$ ]] || { echo 'Bundle has no certificate Team ID' >&2; exit 1; }
for pair in "$core|$app_id.core" "$helper|$helper_id"; do
    binary="${pair%|*}"
    identifier="${pair##*|}"
    /usr/bin/codesign --verify --strict -R="anchor apple generic and identifier \"$identifier\" and certificate leaf[subject.OU] = \"$team\"" "$binary"
done
expected_core="$(/usr/bin/plutil -extract coreSha256 raw -o - "$manifest")"
expected_helper="$(/usr/bin/plutil -extract helperSha256 raw -o - "$manifest")"
[[ "$(/usr/bin/shasum -a 256 "$core" | /usr/bin/awk '{print $1}')" == "$expected_core" ]]
[[ "$(/usr/bin/shasum -a 256 "$helper" | /usr/bin/awk '{print $1}')" == "$expected_helper" ]]
[[ "$(/usr/libexec/PlistBuddy -c 'Print :BundleProgram' "$plist")" == "Contents/Library/LaunchServices/$helper_id" ]]
/usr/bin/plutil -lint "$plist"
echo 'Signed ReClash Helper bundle verified; registration and TUN runtime still require macOS testing.'
