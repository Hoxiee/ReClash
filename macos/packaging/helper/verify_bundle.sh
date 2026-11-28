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
manifest="$bundle/Contents/Resources/manifest.json"
plist="$bundle/Contents/Library/LaunchDaemons/$helper_id.plist"
for binary in "$bundle" "$core" "$helper"; do
    /usr/bin/codesign --verify --strict --all-architectures "$binary"
done
team="$(/usr/bin/codesign -dv --verbose=4 "$bundle" 2>&1 | /usr/bin/sed -n 's/^TeamIdentifier=//p')"
if [[ "$team" =~ ^[A-Z0-9]{10}$ ]] &&
   /usr/bin/codesign --verify --strict -R='anchor apple generic' "$bundle" >/dev/null 2>&1; then
    for pair in "$core|$app_id.core" "$helper|$helper_id"; do
        binary="${pair%|*}"
        identifier="${pair##*|}"
        /usr/bin/codesign --verify --strict -R="anchor apple generic and identifier \"$identifier\" and certificate leaf[subject.OU] = \"$team\"" "$binary"
    done
else
    app_cert_directory="$(/usr/bin/mktemp -d)"
    trap '/bin/rm -rf "$app_cert_directory"' EXIT
    if /usr/bin/codesign -d --extract-certificates="$app_cert_directory/app" "$bundle" >/dev/null 2>&1 &&
       [[ -s "$app_cert_directory/app0" ]]; then
        app_certificate="$(/usr/bin/shasum -a 256 "$app_cert_directory/app0" | /usr/bin/awk '{print $1}')"
        for pair in "$core|$app_id.core" "$helper|$helper_id"; do
            binary="${pair%|*}"
            identifier="${pair##*|}"
            cert_directory="$(/usr/bin/mktemp -d)"
            if ! /usr/bin/codesign -d --extract-certificates="$cert_directory/cert" "$binary" >/dev/null 2>&1 ||
               [[ ! -s "$cert_directory/cert0" ]]; then
                /bin/rm -rf "$cert_directory"
                echo "$binary has no signing certificate" >&2
                exit 1
            fi
            actual_certificate="$(/usr/bin/shasum -a 256 "$cert_directory/cert0" | /usr/bin/awk '{print $1}')"
            /bin/rm -rf "$cert_directory"
            [[ "$actual_certificate" == "$app_certificate" ]] || {
                echo "$binary is not signed by the app certificate" >&2
                exit 1
            }
            actual_identifier="$(/usr/bin/codesign -dvvv "$binary" 2>&1 | /usr/bin/sed -n 's/^Identifier=//p' | /usr/bin/head -1)"
            [[ "$actual_identifier" == "$identifier" ]] || {
                echo "$binary has identifier $actual_identifier, expected $identifier" >&2
                exit 1
            }
        done
    else
        for pair in "$core|$app_id.core" "$helper|$helper_id"; do
            binary="${pair%|*}"
            identifier="${pair##*|}"
            actual_identifier="$(/usr/bin/codesign -dvvv "$binary" 2>&1 | /usr/bin/sed -n 's/^Identifier=//p' | /usr/bin/head -1)"
            [[ "$actual_identifier" == "$identifier" ]] || {
                echo "$binary has identifier $actual_identifier, expected $identifier" >&2
                exit 1
            }
        done
    fi
fi
expected_core="$(/usr/bin/plutil -extract coreSha256 raw -o - "$manifest")"
expected_helper="$(/usr/bin/plutil -extract helperSha256 raw -o - "$manifest")"
[[ "$(/usr/bin/shasum -a 256 "$core" | /usr/bin/awk '{print $1}')" == "$expected_core" ]]
[[ "$(/usr/bin/shasum -a 256 "$helper" | /usr/bin/awk '{print $1}')" == "$expected_helper" ]]
[[ "$(/usr/libexec/PlistBuddy -c 'Print :BundleProgram' "$plist")" == "Contents/Library/LaunchServices/$helper_id" ]]
/usr/bin/plutil -lint "$plist"
echo 'ReClash Helper bundle verified; registration and TUN runtime still require macOS testing.'
