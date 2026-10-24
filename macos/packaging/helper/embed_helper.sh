#!/bin/bash
set -euo pipefail

bundle="$TARGET_BUILD_DIR/$WRAPPER_NAME"
macos="$bundle/Contents/MacOS"
launch_services="$bundle/Contents/Library/LaunchServices"
launch_daemons="$bundle/Contents/Library/LaunchDaemons"
app_id="$PRODUCT_BUNDLE_IDENTIFIER"
helper_id="$app_id.helper"
helper="$BUILT_PRODUCTS_DIR/$helper_id"
core="$macos/ReClashCore"
info="$bundle/Contents/Info.plist"
mkdir -p "$launch_services" "$launch_daemons" "$bundle/Contents/Resources"
if [[ ! -f "$helper" || ! -f "$core" ]]; then
    echo "error: signed Helper target or staged Core is missing"
    exit 1
fi
for binary in "$helper" "$core"; do
    slices="$(/usr/bin/lipo -archs "$binary")"
    for arch in $ARCHS; do
        if [[ " $slices " != *" $arch "* ]]; then
            echo "error: $binary lacks required $arch slice (has $slices)"
            exit 1
        fi
    done
done
cp -f "$helper" "$launch_services/$helper_id"
chmod 755 "$launch_services/$helper_id" "$core"
team="${DEVELOPMENT_TEAM:-}"
signing="${EXPANDED_CODE_SIGN_IDENTITY:-}"
if [[ "${CODE_SIGNING_ALLOWED:-YES}" == YES && -n "$signing" && "$signing" != - && -n "$team" ]]; then
    /usr/bin/codesign --force --timestamp --options runtime --identifier "$app_id.core" --sign "$signing" "$core"
    /usr/bin/codesign --force --timestamp --options runtime --identifier "$helper_id" --sign "$signing" "$launch_services/$helper_id"
    /usr/bin/codesign --verify --strict --all-architectures "$core"
    /usr/bin/codesign --verify --strict --all-architectures "$launch_services/$helper_id"
else
    echo "warning: Privileged TUN is unavailable in ad-hoc/unsigned bundles; the bridge fails closed with bundleInvalid"
fi

cat > "$launch_daemons/$helper_id.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>$helper_id</string>
<key>BundleProgram</key><string>Contents/Library/LaunchServices/$helper_id</string>
<key>MachServices</key><dict><key>$helper_id</key><true/></dict>
<key>AssociatedBundleIdentifiers</key><array><string>$app_id</string></array>
<key>RunAtLoad</key><true/>
<key>ProcessType</key><string>Interactive</string>
<key>ExitTimeOut</key><integer>10</integer>
</dict></plist>
PLIST
requirement="anchor apple generic and identifier \"$helper_id\" and certificate leaf[subject.OU] = \"$team\""
/usr/libexec/PlistBuddy -c 'Delete :SMPrivilegedExecutables' "$info" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Add :SMPrivilegedExecutables dict' "$info"
/usr/libexec/PlistBuddy -c "Add :SMPrivilegedExecutables:$helper_id string $requirement" "$info"
core_hash="$(/usr/bin/shasum -a 256 "$core" | /usr/bin/awk '{print $1}')"
helper_hash="$(/usr/bin/shasum -a 256 "$launch_services/$helper_id" | /usr/bin/awk '{print $1}')"
printf '{"coreSha256":"%s","helperSha256":"%s","helperProtocolVersion":1}\n' "$core_hash" "$helper_hash" > "$bundle/Contents/Resources/manifest.json"
/usr/bin/plutil -lint "$launch_daemons/$helper_id.plist" "$info"
