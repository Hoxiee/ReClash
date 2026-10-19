#!/bin/bash
set -euo pipefail

output="$DERIVED_FILE_DIR/ReClashHelperMetadata"
mkdir -p "$output"
version="$(sed -n 's/^version: \([^ ]*\).*/\1/p' "$SRCROOT/../pubspec.yaml")"
version="${version/+/.}"
app_id="$RECLASH_APP_IDENTIFIER"
helper_id="$app_id.helper"
team="${DEVELOPMENT_TEAM:-}"
if [[ -n "$team" && ! "$team" =~ ^[A-Z0-9]{10}$ ]]; then
    echo "error: DEVELOPMENT_TEAM must be a valid signing Team ID"
    exit 1
fi
app_requirement="anchor apple generic and identifier \"$app_id\" and certificate leaf[subject.OU] = \"$team\""
core_requirement="anchor apple generic and identifier \"$app_id.core\" and certificate leaf[subject.OU] = \"$team\""

cat > "$output/info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>$helper_id</string>
<key>CFBundleName</key><string>ReClash Privileged Helper</string>
<key>CFBundleExecutable</key><string>$helper_id</string>
<key>CFBundleVersion</key><string>$version</string>
<key>CFBundleShortVersionString</key><string>$version</string>
<key>ReClashAppIdentifier</key><string>$app_id</string>
<key>ReClashCoreRequirement</key><string>$core_requirement</string>
<key>SMAuthorizedClients</key><array><string>$app_requirement</string></array>
</dict></plist>
PLIST
cat > "$output/launchd.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>$helper_id</string>
<key>ProgramArguments</key><array><string>/Library/PrivilegedHelperTools/$helper_id</string></array>
<key>MachServices</key><dict><key>$helper_id</key><true/></dict>
<key>AssociatedBundleIdentifiers</key><array><string>$app_id</string></array>
<key>RunAtLoad</key><true/>
<key>ProcessType</key><string>Interactive</string>
<key>ExitTimeOut</key><integer>10</integer>
</dict></plist>
PLIST
/usr/bin/plutil -lint "$output/info.plist" "$output/launchd.plist"
