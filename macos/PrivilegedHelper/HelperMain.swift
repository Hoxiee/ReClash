import Darwin
import Foundation

private func runCoreExec() throws -> Never {
    guard Array(CommandLine.arguments.dropFirst()) == ["--reclash-core-exec", "--bootstrap-fd", "3"],
          getuid() == 0, geteuid() == 0 else {
        throw HelperFailure(code: "bootstrapInvalid", detail: "Only the signed root Helper may execute the Core bootstrap.")
    }
    let identity = try HelperIdentity.current(isHelper: true)
    var parentUid: uid_t = 0
    var parentPid: pid_t = 0
    guard RCSocketPeer(3, &parentUid, &parentPid), parentUid == 0,
          parentPid == getppid(), parentPid > 1,
          let parentCode = RCCopySocketPeerCode(3) else {
        throw HelperFailure(code: "bootstrapInvalid", detail: "The managed bootstrap parent could not be authenticated.")
    }
    try CodeTrust.validate(parentCode, requirement: identity.helperRequirement)
    var buffer = [CChar](repeating: 0, count: 4097)
    let count = rc_read_line(3, &buffer, buffer.count, 5000)
    guard count > 0,
          let value = try JSONSerialization.jsonObject(with:
            Data(buffer.prefix(Int(count)).map { UInt8(bitPattern: $0) })) as? [String: Any],
          Set(value.keys) == Set(["version", "sessionId", "address", "homeDir", "ownerUid", "ownerGid",
                                 "clientPid", "corePath", "coreSha256", "appIdentifier", "accountHome"]),
          value["version"] as? Int == 1,
          let hash = value["coreSha256"] as? String,
          hash.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil,
          let corePath = value["corePath"] as? String,
          let uid = value["ownerUid"] as? UInt32, uid != 0,
          let gid = value["ownerGid"] as? UInt32,
          let home = value["homeDir"] as? String,
          let accountHome = value["accountHome"] as? String,
          let address = value["address"] as? String,
          let session = value["sessionId"] as? String,
          value["appIdentifier"] as? String == identity.appIdentifier else {
        throw HelperFailure(code: "bootstrapInvalid", detail: "The managed bootstrap is malformed.")
    }
    let account = try SecurePaths.accountHome(uid: uid)
    guard account.home == accountHome, account.gid == gid,
          session.range(of: "^[0-9a-f]{32}$", options: .regularExpression) != nil else {
        throw HelperFailure(code: "bootstrapInvalid", detail: "The managed account or session is invalid.")
    }
    _ = try SecurePaths.home(home, uid: uid, appIdentifier: identity.appIdentifier)
    try SecurePaths.socket(address, uid: uid)
    let core = URL(fileURLWithPath: corePath)
    guard core.lastPathComponent == "ReClashCore" else {
        throw HelperFailure(code: "bootstrapInvalid", detail: "The fixed managed Core executable is required.")
    }
    try ManagedCoreStore.verify(core, identity: identity, hash: hash)
    var ready = try JSONSerialization.data(withJSONObject:
        ["execReady": true, "version": 1, "sessionId": session, "pid": getpid()])
    ready.append(10)
    guard ready.withUnsafeBytes({ rc_write_all(3, $0.baseAddress, $0.count, 5000) }) == 0 else {
        throw HelperFailure(code: "bootstrapInvalid", detail: "The managed parent closed before execution.")
    }
    let result = rc_exec_core(core.path, home, accountHome, uid, gid, 3)
    throw HelperFailure(code: "processLaunchFailed", detail: "The sandboxed fixed Core could not execute (\(result)).")
}

@main
struct PrivilegedHelperMain {
    static func main() {
        do {
            if CommandLine.arguments.count > 1 { try runCoreExec() }
            guard getuid() == 0, geteuid() == 0 else {
                throw HelperFailure(code: "bootstrapInvalid", detail: "The Helper must be started by the system service manager.")
            }
            let identity = try HelperIdentity.current(isHelper: true)
            let queue = DispatchQueue(label: "com.reclash.helper.owner")
            let owner = HelperCoreOwner(identity: identity, queue: queue)
            let listener = RCHelperListener(serviceName: identity.serviceName, queue: queue, delegate: owner)
            signal(SIGTERM, SIG_IGN)
            signal(SIGINT, SIG_IGN)
            signal(SIGPIPE, SIG_IGN)
            let terminate = DispatchSource.makeSignalSource(signal: SIGTERM, queue: queue)
            let interrupt = DispatchSource.makeSignalSource(signal: SIGINT, queue: queue)
            let shutdown = {
                owner.shutdown()
                listener.invalidate()
                exit(0)
            }
            terminate.setEventHandler(handler: shutdown)
            interrupt.setEventHandler(handler: shutdown)
            terminate.resume()
            interrupt.resume()
            listener.activate()
            withExtendedLifetime((owner, listener, terminate, interrupt)) { dispatchMain() }
        } catch let failure as HelperFailure {
            fputs("\(failure.code): \(failure.detail)\n", stderr)
            exit(1)
        } catch {
            fputs("privilegedHelperFailed: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }
}
