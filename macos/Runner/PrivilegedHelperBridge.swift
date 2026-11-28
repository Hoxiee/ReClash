import Cocoa
import Darwin
import FlutterMacOS
import ServiceManagement
import Security

final class PrivilegedHelperBridge {
    private let channel: FlutterMethodChannel
    private let queue = DispatchQueue(label: "com.reclash.helper.bridge")
    private let installQueue = DispatchQueue(label: "com.reclash.helper.install")
    private var client: RCHelperClient?
    private var currentIdentity: HelperIdentity?
    private var installInFlight = false

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "reclash/privileged_helper", binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { return }
            self.queue.async { self.handle(call, result: result) }
        }
    }

    deinit { client?.invalidate() }

    private func complete(_ result: @escaping FlutterResult, _ value: Any?) {
        DispatchQueue.main.async { result(value) }
    }

    private func fail(_ result: @escaping FlutterResult, _ failure: HelperFailure,
                      details: [String: Any]? = nil) {
        complete(result, FlutterError(code: failure.code, message: failure.detail, details: details))
    }

    private func runInstallOperation(
        _ operation: @escaping () throws -> Void,
        completion: @escaping (HelperFailure?) -> Void
    ) {
        guard !installInFlight else {
            completion(HelperFailure(code: "registrationBusy", detail: "Another Helper operation is in progress."))
            return
        }
        installInFlight = true
        installQueue.async {
            let failure: HelperFailure?
            do {
                try operation()
                failure = nil
            } catch let error as HelperFailure {
                failure = error
            } catch {
                failure = HelperFailure(code: "registrationFailed", detail: error.localizedDescription)
            }
            self.queue.async {
                self.installInFlight = false
                if failure == nil {
                    self.client?.invalidate()
                    self.client = nil
                }
                completion(failure)
            }
        }
    }

    private func context() throws -> (HelperIdentity, HelperBundle) {
        guard geteuid() != 0 else {
            throw HelperFailure(code: "clientRejected", detail: "Run the ReClash GUI as your ordinary user, not root.")
        }
        let identity = try HelperIdentity.current(isHelper: false)
        let bundle = try HelperBundle.validate(at: Bundle.main.bundleURL, identity: identity, manifest: nil)
        if currentIdentity?.serviceName != identity.serviceName {
            client?.invalidate()
            client = nil
            currentIdentity = identity
        }
        return (identity, bundle)
    }

    private func status(_ identity: HelperIdentity, bundle: HelperBundle) throws -> String {
        if identity.trustMode.isDeveloperID {
            return try signedStatus(identity)
        }
        return try manualStatus(identity, bundle: bundle)
    }

    private func signedStatus(_ identity: HelperIdentity) throws -> String {
        if HelperInstaller.hasManualManifest(identity) {
            return "updateRequired"
        }
        if #available(macOS 13.0, *) {
            switch SMAppService.daemon(plistName: identity.plistName).status {
            case .enabled: return "enabled"
            case .notRegistered: return "notRegistered"
            case .notFound: return "notFound"
            case .requiresApproval: return "requiresApproval"
            @unknown default: return "notFound"
            }
        }
        guard let job = RCCopySystemJob(identity.serviceName) as? [String: Any] else {
            return "notRegistered"
        }
        guard job["Label"] as? String == identity.serviceName,
              let args = job["ProgramArguments"] as? [String],
              args.first == identity.installedHelperPath,
              let requirement = identity.helperRequirement else {
            throw HelperFailure(code: "helperOwnershipMismatch", detail: "The installed Helper registration is not owned by this product.")
        }
        let installed = URL(fileURLWithPath: args[0])
        try SecurePaths.noSymlinks(installed.path)
        try CodeTrust.staticCode(at: installed, requirement: requirement)
        return "enabled"
    }

    private func currentAppExecutableHash() throws -> String {
        guard let executable = Bundle.main.executableURL,
              executable.path == executable.standardizedFileURL.path else {
            throw HelperFailure(code: "bundleInvalid", detail: "The running ReClash executable is unavailable.")
        }
        return try CodeTrust.hash(executable)
    }

    private func launchdJobLoaded(_ identity: HelperIdentity) -> Bool {
        if let job = RCCopySystemJob(identity.serviceName) as? [String: Any] {
            guard job["Label"] as? String == identity.serviceName,
                  let args = job["ProgramArguments"] as? [String],
                  args.first == identity.installedHelperPath else {
                return false
            }
            return true
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["print", "system/\(identity.serviceName)"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func manualStatus(_ identity: HelperIdentity, bundle: HelperBundle) throws -> String {
        guard FileManager.default.fileExists(atPath: identity.installedPlistPath),
              FileManager.default.fileExists(atPath: identity.installedHelperPath) else {
            return "notRegistered"
        }
        if let owner = HelperInstaller.existingOwnerUid(identity), owner != getuid() {
            throw HelperFailure(
                code: "helperOwnedByAnotherUser",
                detail: "This ReClash Helper belongs to another macOS user."
            )
        }
        guard launchdJobLoaded(identity) else {
            return "updateRequired"
        }
        guard let manifest = HelperInstaller.installedManifest(identity) else {
            return "updateRequired"
        }
        guard manifest.protocolVersion == 1,
              manifest.appIdentifier == identity.appIdentifier,
              manifest.trustMode == identity.trustMode.name,
              manifest.ownerUid == getuid() else {
            return "updateRequired"
        }
        switch identity.trustMode {
        case .certificate(let sha256):
            guard let fingerprint = manifest.appCertificateSha256,
                  fingerprint.caseInsensitiveCompare(sha256) == .orderedSame,
                  manifest.helperSha256 == bundle.helperHash,
                  manifest.coreSha256 == bundle.coreHash else {
                return "updateRequired"
            }
        case .adHoc:
            let current: String
            do { current = try currentAppExecutableHash() } catch {
                return "updateRequired"
            }
            guard let expected = manifest.appExecutableSha256,
                  current.caseInsensitiveCompare(expected) == .orderedSame,
                  manifest.helperSha256 == bundle.helperHash,
                  manifest.coreSha256 == bundle.coreHash else {
                return "updateRequired"
            }
        case .developerID:
            return "updateRequired"
        }
        do {
            let installed = try HelperInstaller.installedHelper(identity)
            guard try CodeTrust.hash(installed) == manifest.helperSha256 else {
                return "updateRequired"
            }
        } catch {
            return "updateRequired"
        }
        return "enabled"
    }

    private func send(_ request: [String: Any], identity: HelperIdentity,
                      completion: @escaping (Result<[String: Any], HelperFailure>) -> Void) {
        do {
            let data = try JSONSerialization.data(withJSONObject: request, options: [.sortedKeys])
            if client == nil { client = RCHelperClient(serviceName: identity.serviceName, queue: queue) }
            client!.sendRequest(data) { [weak self] response, peer, error in
                guard let self else { return }
                do {
                    guard let response, let peer, error == nil, peer.uid == 0 else {
                        self.client?.invalidate()
                        self.client = nil
                        throw HelperFailure(code: "helperUnavailable", detail: error?.localizedDescription ?? "The privileged Helper is not responding.")
                    }
                    try CodeTrust.validateService(peer.code, identity: identity)
                    guard let value = try JSONSerialization.jsonObject(with: response) as? [String: Any] else {
                        throw HelperFailure(code: "helperResponseInvalid", detail: "The signed Helper returned an invalid response.")
                    }
                    completion(.success(value))
                } catch let failure as HelperFailure {
                    completion(.failure(failure))
                } catch {
                    completion(.failure(HelperFailure(code: "helperResponseInvalid", detail: error.localizedDescription)))
                }
            }
        } catch {
            completion(.failure(HelperFailure(code: "requestInvalid", detail: error.localizedDescription)))
        }
    }

    private func bundleRequest(_ command: String, bundle: HelperBundle) -> [String: Any] {
        ["method": command, "appPath": bundle.app.path,
         "coreSha256": bundle.coreHash, "helperSha256": bundle.helperHash]
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            let (identity, bundle) = try context()
            switch call.method {
            case "readiness":
                readiness(identity, bundle: bundle, result: result)
            case "register":
                register(identity, bundle: bundle, result: result)
            case "unregister":
                unregister(identity, bundle: bundle, result: result)
            case "start":
                guard let args = call.arguments as? [String: Any],
                      Set(args.keys) == Set(["sessionId", "address", "homeDir", "coreSha256"]),
                      args["coreSha256"] as? String == bundle.coreHash,
                      let session = args["sessionId"] as? String,
                      session.range(of: "^[0-9a-f]{32}$", options: .regularExpression) != nil,
                      let address = args["address"] as? String,
                      let home = args["homeDir"] as? String else {
                    throw HelperFailure(code: "requestInvalid", detail: "The managed Core launch fields are invalid.")
                }
                guard try status(identity, bundle: bundle) == "enabled" else {
                    throw HelperFailure(code: "authorizationRequired", detail: "Enable this signed ReClash Helper explicitly before starting TUN.")
                }
                var request = bundleRequest("start", bundle: bundle)
                request["sessionId"] = session
                request["address"] = address
                request["homeDir"] = home
                send(request, identity: identity) { [weak self] answer in
                    self?.finish(answer, result: result)
                }
            case "stop":
                guard let args = call.arguments as? [String: Any],
                      Set(args.keys) == Set(["sessionId", "timeoutMillis"]),
                      let session = args["sessionId"] as? String,
                      session.range(of: "^[0-9a-f]{32}$", options: .regularExpression) != nil,
                      let timeout = args["timeoutMillis"] as? Int, timeout >= 0, timeout <= 8000 else {
                    throw HelperFailure(code: "requestInvalid", detail: "The Core stop fields are invalid.")
                }
                send(["method": "stop", "sessionId": session, "timeoutMillis": timeout], identity: identity) { [weak self] answer in
                    self?.finish(answer, result: result)
                }
            default:
                complete(result, FlutterMethodNotImplemented)
            }
        } catch let failure as HelperFailure {
            if call.method == "readiness" || call.method == "register" || call.method == "unregister" {
                complete(result, ["status": "notFound", "code": failure.code, "detail": failure.detail])
            } else {
                fail(result, failure)
            }
        } catch {
            fail(result, HelperFailure(code: "helperUnavailable", detail: error.localizedDescription))
        }
    }

    private func finish(_ answer: Result<[String: Any], HelperFailure>, result: @escaping FlutterResult) {
        switch answer {
        case .failure(let error): fail(result, error)
        case .success(let value):
            if let code = value["code"] as? String {
                fail(result, HelperFailure(code: code, detail: value["detail"] as? String ?? code), details: value)
            } else { complete(result, value) }
        }
    }

    private func readiness(_ identity: HelperIdentity, bundle: HelperBundle,
                           result: @escaping FlutterResult) {
        do {
            let serviceStatus = try status(identity, bundle: bundle)
            guard serviceStatus == "enabled" else {
                complete(result, ["status": serviceStatus])
                return
            }
            send(bundleRequest("readiness", bundle: bundle), identity: identity) { [weak self] answer in
                guard let self else { return }
                let errorStatus = identity.trustMode.isDeveloperID ? "enabled" : "updateRequired"
                switch answer {
                case .failure(let error):
                    self.complete(result, ["status": errorStatus, "code": error.code, "detail": error.detail])
                case .success(let value):
                    if let code = value["code"] as? String {
                        self.complete(result, ["status": errorStatus, "code": code,
                                               "detail": value["detail"] as? String ?? code])
                    } else if value["protocolVersion"] as? Int != 1 ||
                                value["trustMode"] as? String != identity.trustMode.name {
                        self.complete(result, ["status": errorStatus, "code": "helperOutdated",
                                               "detail": "Register the Helper from this ReClash version."])
                    } else { self.complete(result, ["status": "enabled"]) }
                }
            }
        } catch let error as HelperFailure {
            complete(result, ["status": identity.trustMode.isDeveloperID ? "notFound" : "updateRequired",
                              "code": error.code, "detail": error.detail])
        } catch {
            if identity.trustMode.isDeveloperID {
                fail(result, HelperFailure(code: "helperUnavailable", detail: error.localizedDescription))
            } else {
                complete(result, ["status": "updateRequired", "code": "helperUnavailable",
                                  "detail": error.localizedDescription])
            }
        }
    }

    private func register(_ identity: HelperIdentity, bundle: HelperBundle,
                          result: @escaping FlutterResult) {
        if !identity.trustMode.isDeveloperID {
            registerManual(identity, bundle: bundle, result: result)
            return
        }
        if HelperInstaller.hasManualManifest(identity) {
            if #available(macOS 13.0, *) {
                try? SMAppService.daemon(plistName: identity.plistName).unregister()
            }
            runInstallOperation({
                try HelperInstaller.removeLaunchdInstallation(identity: identity)
            }) { [weak self] failure in
                guard let self else { return }
                if let failure {
                    self.fail(result, failure)
                    return
                }
                self.registerSigned(identity, bundle: bundle, result: result, refresh: true)
            }
            return
        }
        registerSigned(identity, bundle: bundle, result: result)
    }

    private func registerManual(_ identity: HelperIdentity, bundle: HelperBundle,
                                result: @escaping FlutterResult) {
        do {
            guard try status(identity, bundle: bundle) == "enabled" else {
                installManual(identity, bundle: bundle, result: result)
                return
            }
            send(bundleRequest("prepareUnregister", bundle: bundle), identity: identity) { [weak self] answer in
                guard let self else { return }
                let install: () -> Void = {
                    self.installManual(identity, bundle: bundle, result: result)
                }
                switch answer {
                case .failure(let error):
                    if error.code == "coreStopFailed" {
                        self.fail(result, error)
                    } else {
                        install()
                    }
                case .success(let value):
                    if let code = value["code"] as? String, code == "coreStopFailed" {
                        self.finish(.success(value), result: result)
                    } else {
                        install()
                    }
                }
            }
        } catch let failure as HelperFailure {
            fail(result, failure)
        } catch {
            fail(result, HelperFailure(code: "registrationFailed", detail: error.localizedDescription))
        }
    }

    private func clearSignedRegistration(_ identity: HelperIdentity) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.daemon(plistName: identity.plistName)
            switch service.status {
            case .enabled, .requiresApproval:
                try? service.unregister()
            case .notRegistered, .notFound:
                break
            @unknown default:
                break
            }
        }
    }

    private func installManual(_ identity: HelperIdentity, bundle: HelperBundle,
                               result: @escaping FlutterResult) {
        clearSignedRegistration(identity)
        runInstallOperation({
            try HelperInstaller.install(identity: identity, bundle: bundle)
            usleep(1_000_000)
        }) { [weak self] failure in
            guard let self else { return }
            if let failure {
                self.fail(result, failure)
                return
            }
            self.currentIdentity = identity
            self.readiness(identity, bundle: bundle, result: result)
        }
    }

    private func registerSigned(_ identity: HelperIdentity, bundle: HelperBundle,
                                result: @escaping FlutterResult, refresh: Bool = false) {
        do {
            if #available(macOS 13.0, *) {
                let service = SMAppService.daemon(plistName: identity.plistName)
                if service.status == .enabled {
                    if refresh {
                        try? service.unregister()
                    } else {
                        let current = try? status(identity, bundle: bundle)
                        if current != "enabled" {
                            try? service.unregister()
                        } else {
                        send(bundleRequest("prepareUnregister", bundle: bundle), identity: identity) { [weak self] answer in
                            guard let self else { return }
                            switch answer {
                            case .failure(let error): self.fail(result, error)
                            case .success(let value):
                                if value["code"] != nil { self.finish(.success(value), result: result); return }
                                do {
                                    try service.unregister()
                                    self.client?.invalidate()
                                    self.client = nil
                                    try service.register()
                                    self.readiness(identity, bundle: bundle, result: result)
                                } catch { self.fail(result, HelperFailure(code: "registrationFailed", detail: error.localizedDescription)) }
                            }
                        }
                        return
                    }
                }
                try service.register()
            } else {
                if try status(identity, bundle: bundle) == "enabled" {
                    send(bundleRequest("prepareUnregister", bundle: bundle), identity: identity) { [weak self] answer in
                        guard let self else { return }
                        switch answer {
                        case .failure(let error): self.fail(result, error)
                        case .success(let value):
                            if value["code"] != nil { self.finish(.success(value), result: result); return }
                            self.bless(identity, bundle: bundle, result: result)
                        }
                    }
                    return
                }
                bless(identity, bundle: bundle, result: result)
                return
            }
            }
            readiness(identity, bundle: bundle, result: result)
        } catch let failure as HelperFailure {
            fail(result, failure)
        } catch { fail(result, HelperFailure(code: "registrationFailed", detail: error.localizedDescription)) }
    }

    private func authorize<T>(right: String = kSMRightBlessPrivilegedHelper, _ action: (AuthorizationRef) throws -> T) throws -> T {
        var authorization: AuthorizationRef?
        let created = AuthorizationCreate(nil, nil, [], &authorization)
        guard created == errAuthorizationSuccess, let authorization else {
            throw HelperFailure(code: "authorizationDenied", detail: "Helper authorization could not be created.")
        }
        defer { AuthorizationFree(authorization, []) }
        let status = right.withCString { name -> OSStatus in
            var item = AuthorizationItem(name: name, valueLength: 0, value: nil, flags: 0)
            return withUnsafeMutablePointer(to: &item) { pointer in
                var rights = AuthorizationRights(count: 1, items: pointer)
                return AuthorizationCopyRights(authorization, &rights, nil,
                    [.interactionAllowed, .extendRights, .preAuthorize], nil)
            }
        }
        guard status == errAuthorizationSuccess else {
            throw HelperFailure(code: status == errAuthorizationCanceled ? "authorizationCancelled" : "authorizationDenied",
                                detail: "Privileged Helper registration was not authorized.")
        }
        return try action(authorization)
    }

    private func bless(_ identity: HelperIdentity, bundle: HelperBundle,
                       result: @escaping FlutterResult) {
        do {
            try authorize { authorization in
                var error: Unmanaged<CFError>?
                guard SMJobBless(kSMDomainSystemLaunchd, identity.serviceName as CFString, authorization, &error) else {
                    throw HelperFailure(code: "registrationFailed", detail: error?.takeRetainedValue().localizedDescription ?? "SMJobBless did not register the signed Helper.")
                }
            }
            client?.invalidate()
            client = nil
            readiness(identity, bundle: bundle, result: result)
        } catch let error as HelperFailure { fail(result, error) }
        catch { fail(result, HelperFailure(code: "registrationFailed", detail: error.localizedDescription)) }
    }

    private func uninstallManual(_ identity: HelperIdentity, result: @escaping FlutterResult) {
        if #available(macOS 13.0, *) {
            try? SMAppService.daemon(plistName: identity.plistName).unregister()
        }
        runInstallOperation({
            if identity.trustMode.isDeveloperID {
                try HelperInstaller.removeLaunchdInstallation(identity: identity)
            } else {
                try HelperInstaller.uninstall(identity: identity)
            }
        }) { [weak self] failure in
            guard let self else { return }
            if let failure {
                self.fail(result, failure)
                return
            }
            self.currentIdentity = nil
            self.complete(result, ["status": "notRegistered"])
        }
    }

    private func unregister(_ identity: HelperIdentity, bundle: HelperBundle,
                            result: @escaping FlutterResult) {
        do {
            if !identity.trustMode.isDeveloperID || HelperInstaller.hasManualManifest(identity) {
                uninstallManual(identity, result: result)
                return
            }
            guard try status(identity, bundle: bundle) == "enabled" else {
                if #available(macOS 13.0, *) { try? SMAppService.daemon(plistName: identity.plistName).unregister() }
                complete(result, ["status": "notRegistered"])
                return
            }
            send(bundleRequest("prepareUnregister", bundle: bundle), identity: identity) { [weak self] answer in
                guard let self else { return }
                switch answer {
                case .failure(let error): self.fail(result, error)
                case .success(let value):
                    if value["code"] != nil { self.finish(.success(value), result: result); return }
                    do {
                        if #available(macOS 13.0, *) {
                            try SMAppService.daemon(plistName: identity.plistName).unregister()
                        } else {
                            try self.authorize(right: kSMRightModifySystemDaemons) { authorization in
                                var error: Unmanaged<CFError>?
                                guard SMJobRemove(kSMDomainSystemLaunchd, identity.serviceName as CFString,
                                                  authorization, true, &error) else {
                                    throw HelperFailure(code: "unregisterFailed", detail: error?.takeRetainedValue().localizedDescription ?? "The owned Helper could not be unregistered.")
                                }
                            }
                        }
                        self.client?.invalidate()
                        self.client = nil
                        self.complete(result, ["status": "notRegistered"])
                    } catch let error as HelperFailure { self.fail(result, error) }
                    catch { self.fail(result, HelperFailure(code: "unregisterFailed", detail: error.localizedDescription)) }
                }
            }
        } catch let error as HelperFailure { fail(result, error) }
        catch { fail(result, HelperFailure(code: "unregisterFailed", detail: error.localizedDescription)) }
    }
}
