import CryptoKit
import Darwin
import Foundation
import Security

struct HelperFailure: Error {
    let code: String
    let detail: String

    var payload: [String: Any] { ["code": code, "detail": detail] }
}

struct HelperIdentity {
    let appIdentifier: String
    let helperIdentifier: String
    let teamIdentifier: String

    var serviceName: String { helperIdentifier }
    var plistName: String { "\(helperIdentifier).plist" }
    var appRequirement: String { requirement(appIdentifier) }
    var helperRequirement: String { requirement(helperIdentifier) }
    var coreRequirement: String { requirement("\(appIdentifier).core") }

    private func requirement(_ identifier: String) -> String {
        "anchor apple generic and identifier \"\(identifier)\" and " +
        "certificate leaf[subject.OU] = \"\(teamIdentifier)\""
    }

    static func current(isHelper: Bool) throws -> HelperIdentity {
        let info = try CodeTrust.currentSigningInfo()
        guard let identifier = info[kSecCodeInfoIdentifier as String] as? String,
              let team = info[kSecCodeInfoTeamIdentifier as String] as? String,
              team.range(of: "^[A-Z0-9]{10}$", options: .regularExpression) != nil,
              let flags = info[kSecCodeInfoFlags as String] as? NSNumber,
              flags.uint32Value & 0x2 == 0,
              info[kSecCodeInfoCertificates as String] != nil else {
            throw HelperFailure(code: "bundleInvalid", detail:
                "TUN requires a certificate-signed ReClash app, Helper and Core with the same Team ID. Ad-hoc or unsigned builds cannot register the privileged Helper.")
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
        let identity = HelperIdentity(appIdentifier: appID,
                                      helperIdentifier: "\(appID).helper",
                                      teamIdentifier: team)
        try CodeTrust.validateCurrent(requirement: isHelper ? identity.helperRequirement : identity.appRequirement)
        return identity
    }
}

enum CodeTrust {
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

    static func currentSigningInfo() throws -> [String: Any] {
        var code: SecCode?
        guard SecCodeCopySelf([], &code) == errSecSuccess, let code else {
            throw HelperFailure(code: "bundleInvalid", detail: "The current executable is not signed.")
        }
        var info: CFDictionary?
        guard SecCodeCopySigningInformation(try staticCode(code), SecCSFlags(rawValue: kSecCSSigningInformation), &info) == errSecSuccess,
              let info = info as? [String: Any] else {
            throw HelperFailure(code: "bundleInvalid", detail: "The executable signing information is unavailable.")
        }
        return info
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
        guard SecCodeCheckValidity(code, SecCSFlags(rawValue: kSecCSStrictValidate), expected) == errSecSuccess else {
            throw HelperFailure(code: "clientRejected", detail: "The XPC peer did not satisfy the trusted signing requirement.")
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
        var information: CFDictionary?
        guard SecCodeCopySigningInformation(try staticCode(code), SecCSFlags(rawValue: kSecCSSigningInformation), &information) == errSecSuccess,
              let value = information as? [String: Any],
              let location = value[kSecCodeInfoMainExecutable as String] as? URL else {
            throw HelperFailure(code: "clientRejected", detail: "The signed client executable could not be determined.")
        }
        return location
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

struct HelperBundle {
    let app: URL
    let core: URL
    let helper: URL
    let coreHash: String
    let helperHash: String

    static func validate(at app: URL, identity: HelperIdentity) throws -> HelperBundle {
        guard app.path.hasSuffix(".app"), app.path == app.standardizedFileURL.path else {
            throw HelperFailure(code: "bundleInvalid", detail: "ReClash must run from its intact application bundle.")
        }
        try SecurePaths.noSymlinks(app.path)
        try CodeTrust.staticCode(at: app, requirement: identity.appRequirement)
        let core = app.appendingPathComponent("Contents/MacOS/ReClashCore")
        let helper = app.appendingPathComponent("Contents/Library/LaunchServices/\(identity.helperIdentifier)")
        let manifest = app.appendingPathComponent("Contents/MacOS/manifest.json")
        try SecurePaths.noSymlinks(core.path)
        try SecurePaths.noSymlinks(helper.path)
        try SecurePaths.noSymlinks(manifest.path)
        guard let data = try? Data(contentsOf: manifest), data.count <= 4096,
              let value = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let expectedCore = value["coreSha256"] as? String,
              let expectedHelper = value["helperSha256"] as? String,
              value["helperProtocolVersion"] as? Int == 1,
              expectedCore.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil,
              expectedHelper.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil else {
            throw HelperFailure(code: "bundleInvalid", detail: "The signed Core/Helper manifest is missing. Reinstall a correctly signed ReClash bundle.")
        }
        try CodeTrust.staticCode(at: core, requirement: identity.coreRequirement)
        try CodeTrust.staticCode(at: helper, requirement: identity.helperRequirement)
        guard try CodeTrust.hash(core) == expectedCore,
              try CodeTrust.hash(helper) == expectedHelper else {
            throw HelperFailure(code: "bundleInvalid", detail: "The bundled Core or Helper hash differs from the final signed manifest.")
        }
        return HelperBundle(app: app, core: core, helper: helper,
                            coreHash: expectedCore, helperHash: expectedHelper)
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
        guard address.range(of: "^/tmp/ReClashSocket_[0-9]+\\.sock$", options: .regularExpression) != nil else {
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
