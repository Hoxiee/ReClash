import Darwin
import Foundation

enum HelperInstaller {
    static func install(identity: HelperIdentity, bundle: HelperBundle) throws {
        guard !identity.trustMode.isDeveloperID else {
            throw HelperFailure(code: "registrationFailed", detail: "The signed Helper uses Service Management.")
        }
        guard bundle.app.path.hasSuffix(".app"),
              !bundle.app.path.contains("/AppTranslocation/") else {
            throw HelperFailure(code: "bundleInvalid", detail: "Move ReClash out of the App Translocation path before installing the Helper.")
        }
        guard let appExecutable = Bundle.main.executableURL,
              appExecutable.path.hasPrefix(bundle.app.path + "/Contents/MacOS/"),
              appExecutable.path == appExecutable.standardizedFileURL.path else {
            throw HelperFailure(code: "bundleInvalid", detail: "The running ReClash executable is outside the application bundle.")
        }
        let appInfo = try CodeTrust.currentSigningInfo()
        let appExecutableSha256 = try CodeTrust.hash(appExecutable)
        let appCertificate = CodeTrust.certificateSHA256(appInfo)
        switch identity.trustMode {
        case .certificate(let sha256):
            guard let fingerprint = appCertificate,
                  fingerprint.caseInsensitiveCompare(sha256) == .orderedSame else {
                throw HelperFailure(code: "bundleInvalid", detail: "The app certificate is not the Helper signing certificate.")
            }
        case .adHoc:
            break
        case .developerID:
            break
        }
        if let existingOwner = existingOwnerUid(identity),
           existingOwner != getuid(),
           FileManager.default.fileExists(atPath: identity.installedHelperPath) {
            throw HelperFailure(
                code: "helperOwnedByAnotherUser",
                detail: "This Mac already has a ReClash Helper for another user. Remove it from that account before enabling TUN here."
            )
        }
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let manifest = HelperManifest(
            protocolVersion: 1,
            appIdentifier: identity.appIdentifier,
            ownerUid: getuid(),
            helperSha256: bundle.helperHash,
            coreSha256: bundle.coreHash,
            appExecutableSha256: identity.trustMode.isAdHoc ? appExecutableSha256 : nil,
            appCertificateSha256: identity.trustMode.certificateSHA256,
            appPath: bundle.app.path,
            helperVersion: version,
            trustMode: identity.trustMode.name
        )
        try manifest.validate(identity: identity)
        let data = try JSONEncoder().encode(manifest)
        try runAsRoot(installScript(
            identity: identity,
            bundle: bundle,
            appExecutable: appExecutable,
            appExecutableSha256: appExecutableSha256,
            manifestBase64: data.base64EncodedString(),
            appCertificate: appCertificate
        ))
    }

    static func uninstall(identity: HelperIdentity) throws {
        guard !identity.trustMode.isDeveloperID else {
            throw HelperFailure(code: "unregisterFailed", detail: "The signed Helper uses Service Management.")
        }
        try removeLaunchdInstallation(identity: identity)
    }

    static func removeLaunchdInstallation(identity: HelperIdentity) throws {
        try runAsRoot(uninstallScript(identity: identity))
    }

    static func hasManualManifest(_ identity: HelperIdentity) -> Bool {
        FileManager.default.fileExists(atPath: identity.manifestPath)
    }

    static func existingOwnerUid(_ identity: HelperIdentity) -> UInt32? {
        do { try SecurePaths.manifest(identity.manifestPath) } catch { return nil }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: identity.manifestPath)),
              data.count <= 8192,
              let object = try? JSONSerialization.jsonObject(with: data),
              let value = object as? [String: Any],
              let owner = value["ownerUid"] as? NSNumber else {
            return nil
        }
        let uid = owner.uint32Value
        return uid == 0 ? nil : uid
    }

    static func installedManifest(_ identity: HelperIdentity) -> HelperManifest? {
        try? HelperManifest.load(identity: identity)
    }

    static func installedHelper(_ identity: HelperIdentity) throws -> URL {
        let url = URL(fileURLWithPath: identity.installedHelperPath)
        try SecurePaths.helperFile(url.path)
        try CodeTrust.validateService(at: url, identity: identity)
        return url
    }

    private static func uninstallScript(identity: HelperIdentity) -> String {
        let manifestDirectory = URL(fileURLWithPath: identity.manifestPath)
            .deletingLastPathComponent().path
        let managedCore = "/Library/Application Support/ReClash/ManagedCore/\(identity.appIdentifier)"
        return """
        #!/bin/bash
        set -euo pipefail
        HELPER_ID=\(shellQuote(identity.helperIdentifier))
        /bin/launchctl bootout "system/$HELPER_ID" >/dev/null 2>&1 || true
        /bin/launchctl bootout system \(shellQuote(identity.installedPlistPath)) >/dev/null 2>&1 || true
        for _ in 1 2 3 4 5 6 7 8 9 10; do
            if ! /bin/launchctl print "system/$HELPER_ID" >/dev/null 2>&1; then
                break
            fi
            /bin/sleep 1
        done
        if /bin/launchctl print "system/$HELPER_ID" >/dev/null 2>&1; then
            echo "The ReClash Helper is still running; uninstall aborted." >&2
            exit 1
        fi
        /bin/rm -f \(shellQuote(identity.installedPlistPath)) \(shellQuote(identity.installedHelperPath))
        /bin/rm -rf \(shellQuote(manifestDirectory))
        /bin/rm -rf \(shellQuote(managedCore))
        """
    }

    private static func installScript(
        identity: HelperIdentity,
        bundle: HelperBundle,
        appExecutable: URL,
        appExecutableSha256: String,
        manifestBase64: String,
        appCertificate: String?
    ) -> String {
        let manifestDirectory = URL(fileURLWithPath: identity.manifestPath)
            .deletingLastPathComponent().path
        let mode = identity.trustMode.isAdHoc ? "adHoc" : "certificate"
        return """
        #!/bin/bash
        set -euo pipefail
        umask 077
        APP=\(shellQuote(bundle.app.path))
        APP_EXEC=\(shellQuote(appExecutable.path))
        HELPER_SRC=\(shellQuote(bundle.helper.path))
        CORE_SRC=\(shellQuote(bundle.core.path))
        HELPER_ID=\(shellQuote(identity.helperIdentifier))
        HELPER_DEST=\(shellQuote(identity.installedHelperPath))
        PLIST_DEST=\(shellQuote(identity.installedPlistPath))
        MANIFEST_DIR=\(shellQuote(manifestDirectory))
        MANIFEST_DEST=\(shellQuote(identity.manifestPath))
        EXPECTED_CERT=\(shellQuote(appCertificate ?? ""))
        EXPECTED_APP_SHA=\(shellQuote(appExecutableSha256))
        EXPECTED_HELPER_SHA=\(shellQuote(bundle.helperHash))
        EXPECTED_CORE_SHA=\(shellQuote(bundle.coreHash))
        MODE=\(shellQuote(mode))

        check_cert() {
            local path="$1" expected="$2" dir actual
            dir="$(/usr/bin/mktemp -d)"
            if ! /usr/bin/codesign -d --extract-certificates="$dir/cert" "$path" >/dev/null 2>&1 ||
               [[ ! -s "$dir/cert0" ]]; then
                /bin/rm -rf "$dir"
                return 1
            fi
            actual="$(/usr/bin/shasum -a 256 "$dir/cert0" | /usr/bin/awk '{print $1}')"
            /bin/rm -rf "$dir"
            [[ "$actual" == "$expected" ]]
        }

        check_exec() {
            local path="$1" expected="$2" actual
            actual="$(/usr/bin/shasum -a 256 "$path" | /usr/bin/awk '{print $1}')"
            [[ "$actual" == "$expected" ]]
        }

        /usr/bin/codesign --verify --strict "$APP" >/dev/null
        /usr/bin/codesign --verify --strict "$HELPER_SRC" >/dev/null
        /usr/bin/codesign --verify --strict "$CORE_SRC" >/dev/null
        if [[ "$MODE" == "certificate" ]]; then
            check_cert "$APP" "$EXPECTED_CERT" || exit 1
            check_cert "$HELPER_SRC" "$EXPECTED_CERT" || exit 1
            check_cert "$CORE_SRC" "$EXPECTED_CERT" || exit 1
        else
            check_exec "$APP_EXEC" "$EXPECTED_APP_SHA" || exit 1
        fi
        [[ "$(/usr/bin/shasum -a 256 "$HELPER_SRC" | /usr/bin/awk '{print $1}')" == "$EXPECTED_HELPER_SHA" ]] || exit 1
        [[ "$(/usr/bin/shasum -a 256 "$CORE_SRC" | /usr/bin/awk '{print $1}')" == "$EXPECTED_CORE_SHA" ]] || exit 1

        /bin/launchctl bootout "system/$HELPER_ID" >/dev/null 2>&1 || true
        /bin/launchctl bootout system "$PLIST_DEST" >/dev/null 2>&1 || true
        for _ in 1 2 3 4 5 6 7 8 9 10; do
            if ! /bin/launchctl print "system/$HELPER_ID" >/dev/null 2>&1; then
                break
            fi
            /bin/sleep 1
        done
        /bin/mkdir -p /Library/PrivilegedHelperTools "/Library/Application Support/ReClash/Helper" "$MANIFEST_DIR"
        /usr/sbin/chown root:wheel /Library/PrivilegedHelperTools "/Library/Application Support/ReClash" "/Library/Application Support/ReClash/Helper" "$MANIFEST_DIR"
        /bin/chmod 0755 /Library/PrivilegedHelperTools "/Library/Application Support/ReClash" "/Library/Application Support/ReClash/Helper" "$MANIFEST_DIR"
        /usr/bin/install -o root -g wheel -m 0755 "$HELPER_SRC" "$HELPER_DEST"
        [[ "$(/usr/bin/shasum -a 256 "$HELPER_DEST" | /usr/bin/awk '{print $1}')" == "$EXPECTED_HELPER_SHA" ]] || {
            /bin/rm -f "$HELPER_DEST"
            exit 1
        }
        /usr/bin/codesign --verify --strict "$HELPER_DEST" >/dev/null || {
            /bin/rm -f "$HELPER_DEST"
            exit 1
        }
        if [[ "$MODE" == "certificate" ]]; then
            check_cert "$HELPER_DEST" "$EXPECTED_CERT" || {
                /bin/rm -f "$HELPER_DEST"
                exit 1
            }
        fi
        /usr/bin/printf '%s' \(shellQuote(manifestBase64)) | /usr/bin/base64 -D > "$MANIFEST_DEST"
        /usr/sbin/chown root:wheel "$MANIFEST_DEST"
        /bin/chmod 0644 "$MANIFEST_DEST"

        /bin/cat > "$PLIST_DEST" <<PLIST
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
        <key>Label</key><string>$HELPER_ID</string>
        <key>Program</key><string>$HELPER_DEST</string>
        <key>ProgramArguments</key><array><string>$HELPER_DEST</string></array>
        <key>MachServices</key><dict><key>$HELPER_ID</key><true/></dict>
        <key>RunAtLoad</key><true/>
        <key>ProcessType</key><string>Interactive</string>
        <key>ExitTimeOut</key><integer>10</integer>
        </dict></plist>
        PLIST
        /usr/sbin/chown root:wheel "$PLIST_DEST"
        /bin/chmod 0644 "$PLIST_DEST"
        /usr/bin/plutil -lint "$PLIST_DEST" >/dev/null
        /bin/launchctl enable "system/$HELPER_ID" >/dev/null 2>&1 || true
        for _ in 1 2 3; do
            if /bin/launchctl bootstrap system "$PLIST_DEST" 2>/dev/null; then
                break
            fi
            /bin/sleep 1
        done
        /bin/launchctl kickstart -k "system/$HELPER_ID" >/dev/null 2>&1 || true
        /bin/launchctl print "system/$HELPER_ID" >/dev/null
        """
    }

    private static func runAsRoot(_ script: String) throws {
        let payload = Data(script.utf8).base64EncodedString()
        let command = "/usr/bin/printf '%s' \(shellQuote(payload)) | /usr/bin/base64 -D | /bin/bash"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = [
            "-e",
            "do shell script \(appleScriptLiteral(command)) with administrator privileges",
        ]
        let errorPipe = Pipe()
        process.standardOutput = FileHandle.nullDevice
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let detail = String(data: errorData, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard process.terminationStatus == 0 else {
            if detail.localizedCaseInsensitiveContains("cancel") || detail.contains("(-128)") {
                throw HelperFailure(code: "authorizationCancelled", detail: "Helper installation was cancelled.")
            }
            throw HelperFailure(
                code: "registrationFailed",
                detail: detail.isEmpty ? "The macOS installer did not complete." : detail
            )
        }
    }

    private static func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    private static func appleScriptLiteral(_ value: String) -> String {
        "\"" + value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"") + "\""
    }
}
