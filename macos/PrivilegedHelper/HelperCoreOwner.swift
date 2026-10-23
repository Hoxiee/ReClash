import Darwin
import Foundation

final class ManagedCore {
    let sessionId: String
    let connectionId: String
    let uid: uid_t
    let clientPid: pid_t
    let pid: pid_t
    let lifetimeFD: Int32

    init(sessionId: String, peer: RCHelperPeer, pid: pid_t, lifetimeFD: Int32) {
        self.sessionId = sessionId
        connectionId = peer.connectionID
        uid = peer.uid
        clientPid = peer.pid
        self.pid = pid
        self.lifetimeFD = lifetimeFD
    }

    deinit { close(lifetimeFD) }
}

final class HelperCoreOwner: NSObject, RCHelperListenerDelegate {
    let identity: HelperIdentity
    private var child: ManagedCore?
    private let queue: DispatchQueue
    private var orphanReaper: DispatchSourceTimer?

    init(identity: HelperIdentity, queue: DispatchQueue) {
        self.identity = identity
        self.queue = queue
    }

    func handleRequest(_ request: Data, from peer: RCHelperPeer,
                       reply: @escaping (Data) -> Void) {
        do {
            try CodeTrust.validate(peer.code, requirement: identity.appRequirement)
            guard peer.uid != 0, peer.pid > 1,
                  let value = try JSONSerialization.jsonObject(with: request) as? [String: Any],
                  let command = value["method"] as? String else {
                throw HelperFailure(code: "clientRejected", detail: "Only a signed, unelevated ReClash GUI may use the Helper.")
            }
            let result: [String: Any]
            switch command {
            case "readiness":
                try keys(value, exactly: ["method", "appPath", "coreSha256", "helperSha256"])
                let bundle = try clientBundle(value, peer: peer)
                try validateRunningHelper(bundle)
                result = ["status": "enabled", "protocolVersion": 1]
            case "start":
                try keys(value, exactly: ["method", "sessionId", "address", "homeDir", "coreSha256", "helperSha256", "appPath"])
                result = try start(value, peer: peer)
            case "stop":
                try keys(value, exactly: ["method", "sessionId", "timeoutMillis"])
                result = try stop(value, peer: peer)
            case "prepareUnregister":
                try keys(value, exactly: ["method", "appPath", "coreSha256", "helperSha256"])
                _ = try clientBundle(value, peer: peer)
                if let child {
                    guard child.connectionId == peer.connectionID else {
                        throw HelperFailure(code: "sessionMismatch", detail: "The Helper has a Core owned by another live app connection.")
                    }
                    guard release(child, timeout: 8000) else {
                        throw HelperFailure(code: "coreStopFailed", detail: "Core exit was not confirmed; unregister was not allowed.")
                    }
                }
                result = ["exitConfirmed": true]
            default:
                throw HelperFailure(code: "requestInvalid", detail: "The Helper operation is not supported.")
            }
            reply(encode(result))
        } catch let failure as HelperFailure {
            reply(encode(failure.payload))
        } catch {
            reply(encode(["code": "requestInvalid", "detail": error.localizedDescription]))
        }
    }

    func connectionInvalidated(_ connectionID: String) {
        guard let child, child.connectionId == connectionID else { return }
        if !release(child, timeout: 8000), orphanReaper == nil {
            let timer = DispatchSource.makeTimerSource(queue: queue)
            timer.schedule(deadline: .now() + 1, repeating: 1)
            timer.setEventHandler { [weak self] in
                guard let self, let owned = self.child else { return }
                if self.release(owned, timeout: 2000) {
                    self.orphanReaper?.cancel()
                    self.orphanReaper = nil
                }
            }
            orphanReaper = timer
            timer.resume()
        }
    }

    func shutdown() {
        if let child { _ = release(child, timeout: 8000) }
        orphanReaper?.cancel()
        orphanReaper = nil
    }

    private func keys(_ value: [String: Any], exactly: Set<String>) throws {
        guard Set(value.keys) == exactly else {
            throw HelperFailure(code: "requestInvalid", detail: "The Helper request has unexpected or missing fields.")
        }
    }

    private func encode(_ value: [String: Any]) -> Data {
        (try? JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])) ?? Data("{}".utf8)
    }

    private func clientBundle(_ value: [String: Any], peer: RCHelperPeer) throws -> HelperBundle {
        guard let appPath = value["appPath"] as? String else {
            throw HelperFailure(code: "bundleInvalid", detail: "The signed client app bundle is missing.")
        }
        let app = URL(fileURLWithPath: appPath)
        let executable = try CodeTrust.location(peer.code)
        guard executable.path.hasPrefix(app.path + "/Contents/MacOS/"),
              Bundle(url: app)?.executableURL?.path == executable.path else {
            throw HelperFailure(code: "clientRejected", detail: "The XPC client is not the executable of the requested signed bundle.")
        }
        let bundle = try HelperBundle.validate(at: app, identity: identity)
        guard value["coreSha256"] as? String == bundle.coreHash,
              value["helperSha256"] as? String == bundle.helperHash else {
            throw HelperFailure(code: "bundleInvalid", detail: "The launch hashes do not match the signed bundle.")
        }
        return bundle
    }

    private func validateRunningHelper(_ bundle: HelperBundle) throws {
        let executable = URL(fileURLWithPath: CommandLine.arguments[0])
        guard try CodeTrust.hash(executable) == bundle.helperHash else {
            throw HelperFailure(code: "helperOutdated", detail: "The registered Helper differs from this app. Register this signed app's Helper again.")
        }
    }

    private func start(_ value: [String: Any], peer: RCHelperPeer) throws -> [String: Any] {
        guard let session = value["sessionId"] as? String,
              session.range(of: "^[0-9a-f]{32}$", options: .regularExpression) != nil,
              let address = value["address"] as? String,
              let suppliedHome = value["homeDir"] as? String else {
            throw HelperFailure(code: "requestInvalid", detail: "A valid Core session, address and home are required.")
        }
        if let owned = child {
            if rc_poll_child(owned.pid) == 1 { child = nil }
            else {
                throw HelperFailure(code: "coreStopFailed", detail: "The Helper still owns a Core; stop its session and confirm exit before another launch.")
            }
        }
        let bundle = try clientBundle(value, peer: peer)
        try validateRunningHelper(bundle)
        let home = try SecurePaths.home(suppliedHome, uid: peer.uid,
                                        appIdentifier: identity.appIdentifier)
        try SecurePaths.socket(address, uid: peer.uid)
        let account = try SecurePaths.accountHome(uid: peer.uid)
        let core = try ManagedCoreStore.stage(bundle, identity: identity)
        var descriptors: [Int32] = [-1, -1]
        guard socketpair(AF_UNIX, SOCK_STREAM, 0, &descriptors) == 0 else {
            throw HelperFailure(code: "processLaunchFailed", detail: "The managed Core bootstrap socket could not be created.")
        }
        _ = fcntl(descriptors[0], F_SETFD, FD_CLOEXEC)
        _ = fcntl(descriptors[1], F_SETFD, FD_CLOEXEC)
        var noSignal: Int32 = 1
        _ = setsockopt(descriptors[0], SOL_SOCKET, SO_NOSIGPIPE, &noSignal, socklen_t(MemoryLayout<Int32>.size))
        var pid: pid_t = 0
        let spawn = rc_spawn_bootstrap(CommandLine.arguments[0], descriptors[1], descriptors[0], &pid)
        close(descriptors[1])
        guard spawn == 0, pid > 1 else {
            close(descriptors[0])
            throw HelperFailure(code: "processLaunchFailed", detail: "The signed Helper could not launch the managed Core bootstrap (\(spawn)).")
        }
        let owned = ManagedCore(sessionId: session, peer: peer, pid: pid, lifetimeFD: descriptors[0])
        child = owned
        let bootstrap: [String: Any] = [
            "version": 1, "sessionId": session, "address": address, "homeDir": home,
            "ownerUid": peer.uid, "ownerGid": account.gid, "clientPid": peer.pid,
            "corePath": core.path, "coreSha256": bundle.coreHash,
            "appIdentifier": identity.appIdentifier, "accountHome": account.home,
        ]
        var bytes = encode(bootstrap)
        bytes.append(10)
        let sent = bytes.withUnsafeBytes {
            rc_write_all(owned.lifetimeFD, $0.baseAddress, $0.count, 5000)
        }
        var buffer = [CChar](repeating: 0, count: 4097)
        let execCount = sent == 0 ? rc_read_line(owned.lifetimeFD, &buffer, buffer.count, 15000) : -1
        let execAnswer = execCount > 0 ? try? JSONSerialization.jsonObject(with:
            Data(buffer.prefix(Int(execCount)).map { UInt8(bitPattern: $0) })) as? [String: Any] : nil
        let execReady = execAnswer?["execReady"] as? Bool == true &&
            execAnswer?["version"] as? Int == 1 && execAnswer?["sessionId"] as? String == session &&
            execAnswer?["pid"] as? Int32 == pid
        let forwarded = execReady ? bytes.withUnsafeBytes {
            rc_write_all(owned.lifetimeFD, $0.baseAddress, $0.count, 5000)
        } : -1
        let count = forwarded == 0 ? rc_read_line(owned.lifetimeFD, &buffer, buffer.count, 15000) : -1
        guard count > 0,
              let answer = try? JSONSerialization.jsonObject(with:
                Data(buffer.prefix(Int(max(count, 0))).map { UInt8(bitPattern: $0) })) as? [String: Any],
              answer["ready"] as? Bool == true, answer["version"] as? Int == 1,
              answer["sessionId"] as? String == session, answer["pid"] as? Int32 == pid else {
            let stopped = release(owned, timeout: 8000)
            if !stopped {
                return ["code": "coreStopFailed", "detail": "Bootstrap failed and Core exit is unconfirmed; ownership was retained.",
                        "sessionId": session, "pid": pid]
            }
            throw HelperFailure(code: "bootstrapFailed", detail: "The managed Core did not authenticate its bootstrap.")
        }
        return ["sessionId": session, "pid": pid]
    }

    private func stop(_ value: [String: Any], peer: RCHelperPeer) throws -> [String: Any] {
        guard let session = value["sessionId"] as? String,
              session.range(of: "^[0-9a-f]{32}$", options: .regularExpression) != nil,
              let timeout = value["timeoutMillis"] as? Int, timeout >= 0 else {
            throw HelperFailure(code: "requestInvalid", detail: "A valid session and stop timeout are required.")
        }
        guard let child else { return ["stopped": false, "exitConfirmed": true] }
        guard child.sessionId == session, child.connectionId == peer.connectionID,
              child.uid == peer.uid, child.clientPid == peer.pid else {
            throw HelperFailure(code: "sessionMismatch", detail: "This request does not own the managed Core session.")
        }
        guard release(child, timeout: min(timeout, 8000)) else {
            throw HelperFailure(code: "coreStopFailed", detail: "Core termination was not confirmed; the Helper retained ownership.")
        }
        return ["stopped": true, "exitConfirmed": true]
    }

    private func release(_ owned: ManagedCore, timeout: Int) -> Bool {
        guard rc_stop_child(owned.pid, Int32(timeout)) == 1 else { return false }
        if child === owned { child = nil }
        return true
    }
}

enum ManagedCoreStore {
    static func root(identity: HelperIdentity, hash: String) -> URL {
        URL(fileURLWithPath: "/Library/Application Support/ReClash/ManagedCore/\(identity.appIdentifier)/\(hash)")
    }

    static func stage(_ bundle: HelperBundle, identity: HelperIdentity) throws -> URL {
        let directory = root(identity: identity, hash: bundle.coreHash)
        let directoryFD = try openRootDirectory(directory.path)
        defer { close(directoryFD) }
        let target = directory.appendingPathComponent("ReClashCore")
        var existing = stat()
        if fstatat(directoryFD, "ReClashCore", &existing, AT_SYMLINK_NOFOLLOW) == 0 {
            try verify(target, identity: identity, hash: bundle.coreHash)
            return target
        }
        let source = open(bundle.core.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard source >= 0 else {
            throw HelperFailure(code: "bundleInvalid", detail: "The verified Core could not be staged.")
        }
        defer { close(source) }
        let name = ".core-\(UUID().uuidString)"
        let output = openat(directoryFD, name, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o700)
        guard output >= 0 else {
            throw HelperFailure(code: "processLaunchFailed", detail: "The private managed Core file could not be created.")
        }
        defer { close(output); _ = unlinkat(directoryFD, name, 0) }
        var buffer = [UInt8](repeating: 0, count: 65536)
        while true {
            let count = read(source, &buffer, buffer.count)
            if count == 0 { break }
            guard count > 0 else {
                if errno == EINTR { continue }
                throw HelperFailure(code: "bundleInvalid", detail: "The Core copy could not be read.")
            }
            try buffer.withUnsafeBytes { bytes in
                var offset = 0
                while offset < count {
                    let written = write(output, bytes.baseAddress!.advanced(by: offset), count - offset)
                    if written < 0 && errno == EINTR { continue }
                    guard written > 0 else {
                        throw HelperFailure(code: "processLaunchFailed", detail: "The managed Core could not be written.")
                    }
                    offset += written
                }
            }
        }
        guard fchmod(output, 0o700) == 0, fchown(output, 0, 0) == 0, fsync(output) == 0 else {
            throw HelperFailure(code: "processLaunchFailed", detail: "Managed Core permissions could not be secured.")
        }
        try verify(directory.appendingPathComponent(name), identity: identity, hash: bundle.coreHash)
        guard renameat(directoryFD, name, directoryFD, "ReClashCore") == 0, fsync(directoryFD) == 0 else {
            throw HelperFailure(code: "processLaunchFailed", detail: "The verified Core could not be published atomically.")
        }
        return target
    }

    static func verify(_ core: URL, identity: HelperIdentity, hash: String) throws {
        try SecurePaths.noSymlinks(core.path)
        var info = stat()
        guard lstat(core.path, &info) == 0, info.st_uid == 0, info.st_mode & 0o022 == 0,
              core.deletingLastPathComponent() == root(identity: identity, hash: hash) else {
            throw HelperFailure(code: "bundleInvalid", detail: "The managed Core is outside its immutable root-owned hash directory.")
        }
        try CodeTrust.staticCode(at: core, requirement: identity.coreRequirement)
        guard try CodeTrust.hash(core) == hash else {
            throw HelperFailure(code: "bundleInvalid", detail: "The managed Core hash does not match the final signed manifest.")
        }
    }

    private static func openRootDirectory(_ path: String) throws -> Int32 {
        var fd = open("/", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else { throw HelperFailure(code: "pathInvalid", detail: "The managed Core root could not be opened.") }
        do {
            for component in path.split(separator: "/") {
                let name = String(component)
                if mkdirat(fd, name, 0o700) != 0 && errno != EEXIST {
                    throw HelperFailure(code: "pathInvalid", detail: "The private managed Core directory could not be created.")
                }
                let next = openat(fd, name, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
                guard next >= 0 else { throw HelperFailure(code: "pathInvalid", detail: "The managed Core directory has an unsafe link.") }
                var info = stat()
                if fstat(next, &info) != 0 || info.st_uid != 0 || info.st_mode & 0o022 != 0 {
                    close(next)
                    throw HelperFailure(code: "pathInvalid", detail: "Managed Core ancestors must be root-owned and not writable by other accounts.")
                }
                close(fd)
                fd = next
            }
            return fd
        } catch {
            close(fd)
            throw error
        }
    }
}
