import CryptoKit
import Darwin
import Foundation
import Security

struct HelperFailure: Error {
    let code: String
    let detail: String

    var payload: [String: Any] { ["code": code, "detail": detail] }
}

enum HelperTrustMode: Equatable {
    case developerID(teamIdentifier: String)
    case certificate(sha256: String)
    case adHoc

    var isDeveloperID: Bool {
        if case .developerID = self { return true }
        return false
    }

    var isAdHoc: Bool {
        if case .adHoc = self { return true }
        return false
    }

    var certificateSHA256: String? {
        if case .certificate(let sha256) = self { return sha256 }
        return nil
    }

    var name: String {
        switch self {
        case .developerID: return "developerID"
        case .certificate: return "certificate"
        case .adHoc: return "adHoc"
        }
    }
}

struct HelperIdentity {
    let appIdentifier: String
    let helperIdentifier: String
    let trustMode: HelperTrustMode

    var serviceName: String { helperIdentifier }
    var plistName: String { "\(helperIdentifier).plist" }
    var installedHelperPath: String { "/Library/PrivilegedHelperTools/\(helperIdentifier)" }
    var installedPlistPath: String { "/Library/LaunchDaemons/\(helperIdentifier).plist" }
    var manifestPath: String {
        "/Library/Application Support/ReClash/Helper/\(helperIdentifier)/manifest.json"
    }

    var appRequirement: String? { requirement(appIdentifier) }
    var helperRequirement: String? { requirement(helperIdentifier) }
    var coreRequirement: String? { requirement("\(appIdentifier).core") }

    private func requirement(_ identifier: String) -> String? {
        guard case .developerID(let team) = trustMode else { return nil }
        return "anchor apple generic and identifier \"\(identifier)\" and " +
            "certificate leaf[subject.OU] = \"\(team)\""
    }

    static func current(isHelper: Bool) throws -> HelperIdentity {
        let info = try CodeTrust.currentSigningInfo()
        guard let identifier = info[kSecCodeInfoIdentifier as String] as? String else {
            throw HelperFailure(code: "bundleInvalid", detail: "The executable has no signing identifier.")
        }
        let appID: String
        if isHelper {
            guard let configured = Bundle.main.object(forInfoDictionaryKey: "ReClashAppIdentifier") as? String,
                  configured == "com.reclash" || configured == "com.reclash.debug",
                  identifier == "\(configured).helper" else {
                throw HelperFailure(code: "bundleInvalid", detail: "The privileged Helper identity is invalid.")
            }
            appID = configured
        } else {
            guard identifier == "com.reclash" || identifier == "com.reclash.debug" else {
                throw HelperFailure(code: "bundleInvalid", detail: "The app signing identifier is invalid.")
            }
            appID = identifier
        }
        let identity = HelperIdentity(
            appIdentifier: appID,
            helperIdentifier: "\(appID).helper",
            trustMode: detectTrustMode(from: info)
        )
        switch identity.trustMode {
        case .developerID:
            guard let requirement = isHelper ? identity.helperRequirement : identity.appRequirement else {
                throw HelperFailure(code: "bundleInvalid", detail: "The Developer ID requirement is missing.")
            }
            try CodeTrust.validateCurrent(requirement: requirement)
        case .certificate(let sha256):
            try CodeTrust.validateCurrentCertificate(identifier: identifier, sha256: sha256)
        case .adHoc:
            try CodeTrust.validateCurrentAdHoc(identifier: identifier)
        }
        return identity
    }

    private static func detectTrustMode(from info: [String: Any]) -> HelperTrustMode {
        let flags = (info[kSecCodeInfoFlags as String] as? NSNumber)?.uint32Value ?? 0
        let team = info[kSecCodeInfoTeamIdentifier as String] as? String
        if flags & 0x2 == 0,
           let team,
           team.range(of: "^[A-Z0-9]{10}$", options: .regularExpression) != nil,
           (try? CodeTrust.validateCurrent(requirement: CodeTrust.developerIDMarker)) != nil {
            return .developerID(teamIdentifier: team)
        }
        if flags & 0x2 == 0, let sha256 = CodeTrust.certificateSHA256(info) {
            return .certificate(sha256: sha256)
        }
        return .adHoc
    }
}

enum CodeTrust {
    static let developerIDMarker =
        "anchor apple generic and certificate leaf[field.1.2.840.113635.100.6.1.13] exists"

    static func requirement(_ text: String) throws -> SecRequirement {
        var value: SecRequirement?
        guard SecRequirementCreateWithString(text as CFString, [], &value) == errSecSuccess,
              let value else {
            throw HelperFailure(code: "bundleInvalid", detail: "A designated signing requirement could not be read.")
        }
        return value
    }

    static func staticCode(_ code: SecCode) throws -> SecStaticCode {
        var value: SecStaticCode?
        guard SecCodeCopyStaticCode(code, [], &value) == errSecSuccess, let value else {
            throw HelperFailure(code: "bundleInvalid", detail: "The executable signing information is unavailable.")
        }
        return value
    }

    static func signingInformation(_ code: SecCode) throws -> [String: Any] {
        var info: CFDictionary?
        guard SecCodeCopySigningInformation(
            try staticCode(code),
            SecCSFlags(rawValue: kSecCSSigningInformation),
            &info
        ) == errSecSuccess, let info = info as? [String: Any] else {
            throw HelperFailure(code: "bundleInvalid", detail: "The executable signing information is unavailable.")
        }
        return info
    }

    static func signingInformation(at url: URL) throws -> [String: Any] {
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess,
              let code else {
            throw HelperFailure(code: "bundleInvalid", detail: "The bundled executable is not signed.")
        }
        var info: CFDictionary?
        guard SecCodeCopySigningInformation(
            code,
            SecCSFlags(rawValue: kSecCSSigningInformation),
            &info
        ) == errSecSuccess, let info = info as? [String: Any] else {
            throw HelperFailure(code: "bundleInvalid", detail: "The bundled executable signing information is unavailable.")
        }
        return info
    }

    static func currentSigningInfo() throws -> [String: Any] {
        var code: SecCode?
        guard SecCodeCopySelf([], &code) == errSecSuccess, let code else {
            throw HelperFailure(code: "bundleInvalid", detail: "The current executable is not signed.")
        }
        return try signingInformation(code)
    }

    static func validateCurrent(requirement: String) throws {
        var code: SecCode?
        guard SecCodeCopySelf([], &code) == errSecSuccess, let code else {
            throw HelperFailure(code: "bundleInvalid", detail: "The executable signature is unavailable.")
        }
        try validate(code, requirement: requirement)
    }

    static func validate(_ code: SecCode, requirement: String) throws {
        let expected = try self.requirement(requirement)
        guard SecCodeCheckValidity(
            code,
            SecCSFlags(rawValue: kSecCSStrictValidate),
            expected
        ) == errSecSuccess else {
            throw HelperFailure(code: "clientRejected", detail: "The peer did not satisfy the trusted signing requirement.")
        }
    }

    static func validateIntegrity(_ code: SecCode) throws {
        guard SecCodeCheckValidity(
            code,
            SecCSFlags(rawValue: kSecCSStrictValidate),
            nil
        ) == errSecSuccess else {
            throw HelperFailure(code: "bundleInvalid", detail: "The executable signature is damaged.")
        }
    }

    static func validateIntegrity(at url: URL) throws {
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess,
              let code else {
            throw HelperFailure(code: "bundleInvalid", detail: "The bundled executable is not signed.")
        }
        guard SecStaticCodeCheckValidity(
            code,
            SecCSFlags(rawValue: kSecCSStrictValidate | kSecCSCheckAllArchitectures),
            nil
        ) == errSecSuccess else {
            throw HelperFailure(code: "bundleInvalid", detail: "The bundled executable signature is damaged.")
        }
    }

    static func validateCurrentCertificate(identifier: String, sha256: String) throws {
        var code: SecCode?
        guard SecCodeCopySelf([], &code) == errSecSuccess, let code else {
            throw HelperFailure(code: "bundleInvalid", detail: "The executable signature is unavailable.")
        }
        try validateCertificate(code, identifier: identifier, sha256: sha256)
    }

    static func validateCertificate(_ code: SecCode, identifier: String, sha256: String) throws {
        let info = try signingInformation(code)
        guard info[kSecCodeInfoIdentifier as String] as? String == identifier,
              let fingerprint = certificateSHA256(info),
              fingerprint.caseInsensitiveCompare(sha256) == .orderedSame else {
            throw HelperFailure(code: "clientRejected", detail: "The peer certificate is not the ReClash signing certificate.")
        }
        try validateIntegrity(code)
    }

    static func validateCertificate(at url: URL, identifier: String, sha256: String) throws {
        let info = try signingInformation(at: url)
        guard info[kSecCodeInfoIdentifier as String] as? String == identifier,
              let fingerprint = certificateSHA256(info),
              fingerprint.caseInsensitiveCompare(sha256) == .orderedSame else {
            throw HelperFailure(code: "bundleInvalid", detail: "A bundled executable is not signed by the ReClash certificate.")
        }
        try validateIntegrity(at: url)
    }

    static func validateCurrentAdHoc(identifier: String) throws {
        var code: SecCode?
        guard SecCodeCopySelf([], &code) == errSecSuccess, let code else {
            throw HelperFailure(code: "bundleInvalid", detail: "The executable signature is unavailable.")
        }
        try validateAdHoc(code, identifier: identifier)
    }

    static func validateAdHoc(_ code: SecCode, identifier: String,
                              appExecutableSha256: String? = nil) throws {
        let info = try signingInformation(code)
        guard info[kSecCodeInfoIdentifier as String] as? String == identifier else {
            throw HelperFailure(code: "clientRejected", detail: "The peer identifier is not ReClash.")
        }
        guard isAdHoc(info) else {
            throw HelperFailure(code: "clientRejected", detail: "The peer is not ad-hoc signed.")
        }
        if let expected = appExecutableSha256 {
            let executable = try location(code)
            let actual = try hash(executable)
            guard actual.caseInsensitiveCompare(expected) == .orderedSame else {
                throw HelperFailure(code: "clientRejected", detail: "The peer build differs from the installed ReClash bundle.")
            }
        }
        try validateIntegrity(code)
    }

    static func validateClient(_ code: SecCode, identity: HelperIdentity, manifest: HelperManifest?) throws {
        switch identity.trustMode {
        case .developerID:
            guard let requirement = identity.appRequirement else {
                throw HelperFailure(code: "clientRejected", detail: "The Developer ID requirement is missing.")
            }
            try validate(code, requirement: requirement)
        case .certificate(let sha256):
            try validateCertificate(code, identifier: identity.appIdentifier, sha256: sha256)
        case .adHoc:
            guard let manifest, let expected = manifest.appExecutableSha256 else {
                throw HelperFailure(code: "helperOutdated", detail: "The installed Helper has no app build pin.")
            }
            try validateAdHoc(code, identifier: identity.appIdentifier,
                              appExecutableSha256: expected)
        }
    }

    static func validateService(_ code: SecCode, identity: HelperIdentity) throws {
        switch identity.trustMode {
        case .developerID:
            guard let requirement = identity.helperRequirement else {
                throw HelperFailure(code: "helperUnavailable", detail: "The Developer ID requirement is missing.")
            }
            try validate(code, requirement: requirement)
        case .certificate(let sha256):
            try validateCertificate(code, identifier: identity.helperIdentifier, sha256: sha256)
        case .adHoc:
            try validateAdHoc(code, identifier: identity.helperIdentifier)
        }
    }

    static func validateService(at url: URL, identity: HelperIdentity) throws {
        switch identity.trustMode {
        case .developerID:
            guard let requirement = identity.helperRequirement else {
                throw HelperFailure(code: "helperUnavailable", detail: "The Developer ID requirement is missing.")
            }
            try staticCode(at: url, requirement: requirement)
        case .certificate(let sha256):
            try validateCertificate(at: url, identifier: identity.helperIdentifier, sha256: sha256)
        case .adHoc:
            let info = try signingInformation(at: url)
            guard isAdHoc(info),
                  info[kSecCodeInfoIdentifier as String] as? String == identity.helperIdentifier else {
                throw HelperFailure(code: "helperUnavailable", detail: "The installed Helper is not ad-hoc signed as ReClash.")
            }
            try validateIntegrity(at: url)
        }
    }

    static func validateParent(
        _ code: SecCode,
        identity: HelperIdentity,
        manifest: HelperManifest?,
        helperExecutable: String
    ) throws {
        switch identity.trustMode {
        case .developerID:
            guard let requirement = identity.helperRequirement else {
                throw HelperFailure(code: "bootstrapInvalid", detail: "The Developer ID requirement is missing.")
            }
            try validate(code, requirement: requirement)
        case .certificate(let sha256):
            try validateCertificate(code, identifier: identity.helperIdentifier, sha256: sha256)
        case .adHoc:
            let info = try signingInformation(code)
            let helperHash = try hash(URL(fileURLWithPath: helperExecutable))
            guard isAdHoc(info),
                  info[kSecCodeInfoIdentifier as String] as? String == identity.helperIdentifier,
                  (info[kSecCodeInfoMainExecutable as String] as? URL)?.path == helperExecutable,
                  let manifest,
                  helperHash == manifest.helperSha256 else {
                throw HelperFailure(code: "bootstrapInvalid", detail: "The managed Helper parent is not the installed ReClash Helper.")
            }
            try validateIntegrity(code)
        }
    }

    static func staticCode(at url: URL, requirement: String) throws {
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess, let code,
              SecStaticCodeCheckValidity(code,
                SecCSFlags(rawValue: kSecCSStrictValidate | kSecCSCheckAllArchitectures),
                try self.requirement(requirement)) == errSecSuccess else {
            throw HelperFailure(code: "bundleInvalid", detail: "A bundled executable failed signature verification: \(url.lastPathComponent).")
        }
    }

    static func location(_ code: SecCode) throws -> URL {
        let information = try signingInformation(code)
        guard let location = information[kSecCodeInfoMainExecutable as String] as? URL else {
            throw HelperFailure(code: "clientRejected", detail: "The signed client executable could not be determined.")
        }
        return location
    }

    static func isAdHoc(_ info: [String: Any]) -> Bool {
        let flags = (info[kSecCodeInfoFlags as String] as? NSNumber)?.uint32Value ?? 0
        return flags & 0x2 != 0
    }

    static func certificateSHA256(_ info: [String: Any]) -> String? {
        guard let certificates = info[kSecCodeInfoCertificates as String] as? [SecCertificate],
              let leaf = certificates.first else { return nil }
        let data = SecCertificateCopyData(leaf) as Data
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func hash(_ url: URL) throws -> String {
        let fd = open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else {
            throw HelperFailure(code: "bundleInvalid", detail: "A bundled executable could not be opened safely.")
        }
        defer { close(fd) }
        var metadata = stat()
        guard fstat(fd, &metadata) == 0, metadata.st_mode & S_IFMT == S_IFREG,
              metadata.st_nlink == 1, metadata.st_mode & 0o6022 == 0 else {
            throw HelperFailure(code: "bundleInvalid", detail: "Executable permissions or links are unsafe.")
        }
        var digest = SHA256()
        var buffer = [UInt8](repeating: 0, count: 65536)
        while true {
            let count = read(fd, &buffer, buffer.count)
            if count == 0 { break }
            if count < 0 {
                if errno == EINTR { continue }
                throw HelperFailure(code: "bundleInvalid", detail: "The executable hash could not be calculated.")
            }
            digest.update(data: Data(buffer.prefix(count)))
        }
        return digest.finalize().map { String(format: "%02x", $0) }.joined()
    }
}

struct HelperManifest: Codable {
    let protocolVersion: Int
    let appIdentifier: String
    let ownerUid: UInt32
    let helperSha256: String
    let coreSha256: String
    let appExecutableSha256: String?
    let appCertificateSha256: String?
    let appPath: String
    let helperVersion: String
    let trustMode: String

    static func load(identity: HelperIdentity) throws -> HelperManifest {
        let path = identity.manifestPath
        try SecurePaths.manifest(path)
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              data.count <= 8192,
              let manifest = try? JSONDecoder().decode(HelperManifest.self, from: data) else {
            throw HelperFailure(code: "helperOutdated", detail: "The installed Helper manifest is missing or invalid.")
        }
        try manifest.validate(identity: identity)
        return manifest
    }

    func validate(identity: HelperIdentity) throws {
        guard protocolVersion == 1,
              trustMode == identity.trustMode.name,
              appIdentifier == identity.appIdentifier,
              ownerUid != 0,
              Self.isSHA256(helperSha256),
              Self.isSHA256(coreSha256),
              Self.isOptionalSHA256(appExecutableSha256),
              Self.isOptionalSHA256(appCertificateSha256),
              appPath.hasSuffix(".app"),
              appPath == URL(fileURLWithPath: appPath).standardizedFileURL.path,
              !helperVersion.isEmpty else {
            throw HelperFailure(code: "helperOutdated", detail: "The installed Helper manifest does not match this build.")
        }
        switch identity.trustMode {
        case .developerID:
            break
        case .certificate(let sha256):
            guard let fingerprint = appCertificateSha256,
                  fingerprint.caseInsensitiveCompare(sha256) == .orderedSame else {
                throw HelperFailure(code: "helperOutdated", detail: "The installed Helper belongs to a different signing certificate.")
            }
        case .adHoc:
            guard appExecutableSha256 != nil else {
                throw HelperFailure(code: "helperOutdated", detail: "The installed Helper has no app build pin.")
            }
        }
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil
    }

    private static func isOptionalSHA256(_ value: String?) -> Bool {
        guard let value else { return true }
        return isSHA256(value)
    }
}

struct HelperBundle {
    let app: URL
    let core: URL
    let helper: URL
    let coreHash: String
    let helperHash: String
    let appCertificateSha256: String?

    static func validate(
        at app: URL,
        identity: HelperIdentity,
        manifest: HelperManifest?
    ) throws -> HelperBundle {
        guard app.path.hasSuffix(".app"), app.path == app.standardizedFileURL.path else {
            throw HelperFailure(code: "bundleInvalid", detail: "ReClash must run from its intact application bundle.")
        }
        try SecurePaths.noSymlinks(app.path)
        let appInfo: [String: Any]
        switch identity.trustMode {
        case .developerID:
            guard let requirement = identity.appRequirement else {
                throw HelperFailure(code: "bundleInvalid", detail: "The Developer ID requirement is missing.")
            }
            try CodeTrust.staticCode(at: app, requirement: requirement)
            appInfo = try CodeTrust.signingInformation(at: app)
        case .certificate(let sha256):
            try CodeTrust.validateCertificate(at: app, identifier: identity.appIdentifier, sha256: sha256)
            appInfo = try CodeTrust.signingInformation(at: app)
        case .adHoc:
            try CodeTrust.validateIntegrity(at: app)
            appInfo = try CodeTrust.signingInformation(at: app)
            guard CodeTrust.isAdHoc(appInfo),
                  appInfo[kSecCodeInfoIdentifier as String] as? String == identity.appIdentifier else {
                throw HelperFailure(code: "bundleInvalid", detail: "The unsigned app is not ad-hoc signed as ReClash.")
            }
        }
        let appCertificate = CodeTrust.certificateSHA256(appInfo)
        if case .certificate(let sha256) = identity.trustMode {
            guard let fingerprint = appCertificate,
                  fingerprint.caseInsensitiveCompare(sha256) == .orderedSame else {
                throw HelperFailure(code: "bundleInvalid", detail: "The app certificate is not the ReClash signing certificate.")
            }
        }

        let core = app.appendingPathComponent("Contents/MacOS/ReClashCore")
        let helper = app.appendingPathComponent("Contents/Library/LaunchServices/\(identity.helperIdentifier)")
        let manifestURL = app.appendingPathComponent("Contents/Resources/manifest.json")
        try SecurePaths.noSymlinks(core.path)
        try SecurePaths.noSymlinks(helper.path)
        try SecurePaths.noSymlinks(manifestURL.path)
        guard let data = try? Data(contentsOf: manifestURL), data.count <= 4096,
              let value = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let expectedCore = value["coreSha256"] as? String,
              let expectedHelper = value["helperSha256"] as? String,
              value["helperProtocolVersion"] as? Int == 1,
              expectedCore.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil,
              expectedHelper.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil else {
            throw HelperFailure(code: "bundleInvalid", detail: "The Core/Helper manifest is missing. Reinstall ReClash.")
        }

        switch identity.trustMode {
        case .developerID:
            guard let coreRequirement = identity.coreRequirement,
                  let helperRequirement = identity.helperRequirement else {
                throw HelperFailure(code: "bundleInvalid", detail: "The Developer ID requirements are missing.")
            }
            try CodeTrust.staticCode(at: core, requirement: coreRequirement)
            try CodeTrust.staticCode(at: helper, requirement: helperRequirement)
        case .certificate(let sha256):
            try CodeTrust.validateCertificate(at: core, identifier: "\(identity.appIdentifier).core", sha256: sha256)
            try CodeTrust.validateCertificate(at: helper, identifier: identity.helperIdentifier, sha256: sha256)
        case .adHoc:
            let coreInfo = try CodeTrust.signingInformation(at: core)
            let helperInfo = try CodeTrust.signingInformation(at: helper)
            guard CodeTrust.isAdHoc(coreInfo),
                  CodeTrust.isAdHoc(helperInfo),
                  coreInfo[kSecCodeInfoIdentifier as String] as? String == "\(identity.appIdentifier).core",
                  helperInfo[kSecCodeInfoIdentifier as String] as? String == identity.helperIdentifier else {
                throw HelperFailure(code: "bundleInvalid", detail: "The unsigned Core or Helper is not ad-hoc signed as ReClash.")
            }
            try CodeTrust.validateIntegrity(at: core)
            try CodeTrust.validateIntegrity(at: helper)
        }

        let coreHash = try CodeTrust.hash(core)
        let helperHash = try CodeTrust.hash(helper)
        guard coreHash == expectedCore, helperHash == expectedHelper else {
            throw HelperFailure(code: "bundleInvalid", detail: "The Core or Helper hash differs from the final manifest.")
        }
        if let manifest, !identity.trustMode.isDeveloperID {
            guard helperHash == manifest.helperSha256,
                  coreHash == manifest.coreSha256 else {
                throw HelperFailure(code: "helperOutdated", detail: "The Core or Helper differs from the installed pin. Reinstall the Helper.")
            }
        }
        return HelperBundle(
            app: app,
            core: core,
            helper: helper,
            coreHash: coreHash,
            helperHash: helperHash,
            appCertificateSha256: appCertificate
        )
    }
}

enum SecurePaths {
    static func noSymlinks(_ path: String) throws {
        guard path.hasPrefix("/"), path == URL(fileURLWithPath: path).standardizedFileURL.path,
              !path.utf8.contains(0), path.utf8.count < 1024 else {
            throw HelperFailure(code: "pathInvalid", detail: "An absolute canonical path is required.")
        }
        var current = ""
        for component in path.split(separator: "/") {
            current += "/\(component)"
            var info = stat()
            guard lstat(current, &info) == 0, info.st_mode & S_IFMT != S_IFLNK else {
                throw HelperFailure(code: "pathInvalid", detail: "Symlinks and missing path components are not accepted.")
            }
        }
    }

    static func manifest(_ path: String) throws {
        try noSymlinks(path)
        var info = stat()
        guard lstat(path, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
              info.st_uid == 0, info.st_mode & 0o022 == 0, info.st_nlink == 1 else {
            throw HelperFailure(code: "helperOutdated", detail: "The installed Helper manifest is not root-owned and immutable.")
        }
    }

    static func helperFile(_ path: String) throws {
        try noSymlinks(path)
        var info = stat()
        guard lstat(path, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
              info.st_uid == 0, info.st_mode & 0o022 == 0, info.st_nlink == 1 else {
            throw HelperFailure(code: "helperOutdated", detail: "The installed Helper is not root-owned and immutable.")
        }
    }

    static func accountHome(uid: uid_t) throws -> (home: String, gid: gid_t) {
        guard uid != 0, let account = getpwuid(uid), let directory = account.pointee.pw_dir else {
            throw HelperFailure(code: "clientRejected", detail: "A non-root signed GUI account is required.")
        }
        let home = String(cString: directory)
        try noSymlinks(home)
        return (home, account.pointee.pw_gid)
    }

    static func home(_ supplied: String, uid: uid_t, appIdentifier: String) throws -> String {
        let account = try accountHome(uid: uid)
        let expected = "\(account.home)/Library/Application Support/\(appIdentifier)"
        guard supplied == expected else {
            throw HelperFailure(code: "homeInvalid", detail: "Core home must be the authenticated client's ReClash application-support directory.")
        }
        try noSymlinks(supplied)
        var info = stat()
        guard lstat(supplied, &info) == 0, info.st_mode & S_IFMT == S_IFDIR,
              info.st_uid == uid, info.st_mode & 0o022 == 0 else {
            throw HelperFailure(code: "homeInvalid", detail: "Core home must be owned by the signed client and not writable by other accounts.")
        }
        return supplied
    }

    static func socket(_ address: String, uid: uid_t) throws {
        guard address.range(of: "^/tmp/ReClashSocket_[0-9a-f]{32}\\.sock$", options: .regularExpression) != nil else {
            throw HelperFailure(code: "addressInvalid", detail: "The Core socket address is outside ReClash's IPC namespace.")
        }
        var info = stat()
        let resolved = "/private\(address)"
        guard lstat(resolved, &info) == 0, info.st_mode & S_IFMT == S_IFSOCK,
              info.st_uid == uid, info.st_mode & 0o777 == 0o600 else {
            throw HelperFailure(code: "addressInvalid", detail: "The Core socket must be private and owned by the signed client.")
        }
    }
}
