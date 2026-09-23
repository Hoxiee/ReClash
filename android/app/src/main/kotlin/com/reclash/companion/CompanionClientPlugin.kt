package com.reclash.companion

import android.content.Context
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.reclash.common.GlobalState
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import java.security.SecureRandom
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

// Phone-facing method channel: parse QR, run the pinned pairing handshake, seal credentials. All
// network work is off the main thread; the pending token is persisted before POST so a lost
// approval response never forces a re-pair (S07). A pin mismatch aborts before any Authorization.
class CompanionClientPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private val gson = Gson()
    private val random = SecureRandom()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler(this@CompanionClientPlugin)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        val context = GlobalState.application
        when (call.method) {
            "pair" -> {
                val raw = call.argument<String>("raw")
                val clientName = call.argument<String>("clientName")?.takeIf { it.isNotBlank() }
                    ?: android.os.Build.MODEL ?: "Phone"
                asyncResult(result) { pair(context, raw, clientName) }
            }
            "pollPairing" -> {
                val deviceId = call.argument<String>("deviceId")
                asyncResult(result) { pollPairing(context, deviceId) }
            }
            "forget" -> {
                val deviceId = call.argument<String>("deviceId")
                asyncResult(result) { forget(context, deviceId) }
            }
            "targets" -> result.success(CompanionCredentialStore(context).list().map(::targetMap))
            "readState" -> {
                val deviceId = call.argument<String>("deviceId")
                asyncResult(result) { read(context, deviceId, "/v1/state") }
            }
            "readProfiles" -> {
                val deviceId = call.argument<String>("deviceId")
                asyncResult(result) { read(context, deviceId, "/v1/profiles") }
            }
            "readGroups" -> {
                val deviceId = call.argument<String>("deviceId")
                asyncResult(result) { read(context, deviceId, "/v1/groups") }
            }
            "command" -> {
                val deviceId = call.argument<String>("deviceId")
                val kind = call.argument<String>("kind")
                val arguments = call.argument<Map<String, Any?>>("arguments") ?: emptyMap()
                asyncResult(result) { command(context, deviceId, kind, arguments) }
            }
            "rename" -> rename(context, call, result)
            else -> result.notImplemented()
        }
    }

    private fun pair(context: Context, raw: String?, clientName: String): Map<String, Any?> {
        if (raw == null) return failure("invalidInput")
        val parsed = parseCompanionPairingQr(raw)
        if (parsed !is CompanionQrPaired) {
            return failure((parsed as CompanionQrRejected).reason.name)
        }
        val payload = parsed.payload
        val store = CompanionCredentialStore(context)
        val network = CompanionNetwork(context).selectLanEndpoint()?.network
        val client = CompanionClient(payload.spkiPin, network)

        val clientId = randomB64(16)
        val clientToken = randomB64(32)
        val requestBody = gson.toJson(
            mapOf(
                "pairingSecret" to payload.pairingSecret,
                "clientId" to clientId,
                "clientName" to clientName,
                "clientToken" to clientToken,
                "protocolMin" to 1,
                "protocolMax" to 1,
            ),
        )

        val response = try {
            client.submitPairing(payload.baseUrl, requestBody)
        } catch (_: Exception) {
            return failure("identityChanged")
        }
        if (response.code != 202) {
            return failure(errorCode(response.body))
        }
        val json = JsonParser.parseString(response.body).asJsonObject
        val pairingId = json.get("pairingId").asString

        // Persist pending before returning: the phone already holds the token if approval is lost.
        store.put(
            CompanionTarget(
                deviceId = payload.deviceId,
                clientId = clientId,
                clientName = clientName,
                token = clientToken,
                spkiPin = payload.spkiPin,
                host = payload.host,
                port = payload.port,
                pairingId = pairingId,
                active = false,
            ),
        )
        return mapOf(
            "ok" to true,
            "deviceId" to payload.deviceId,
            "pairingId" to pairingId,
            "confirmationCode" to json.get("confirmationCode")?.asString,
        )
    }

    private fun pollPairing(context: Context, deviceId: String?): Map<String, Any?> {
        if (deviceId == null) return failure("invalidInput")
        val store = CompanionCredentialStore(context)
        val target = store.find(deviceId) ?: return failure("pairingExpired")
        val network = CompanionNetwork(context).selectLanEndpoint()?.network
        val client = CompanionClient(target.spkiPin, network)
        val response = try {
            client.pollPairing(target.baseUrl(), target.pairingId, target.token)
        } catch (_: Exception) {
            return failure("identityChanged")
        }
        if (response.code != 200) return failure(mappedErrorCode(response.body))
        val phase = JsonParser.parseString(response.body).asJsonObject.get("phase")?.asString
        if (phase == "approved") {
            store.markActive(deviceId)
        }
        return mapOf("ok" to true, "phase" to (phase ?: "pending"))
    }

    private fun read(context: Context, deviceId: String?, path: String): Map<String, Any?> {
        if (deviceId == null) return failure("invalidInput")
        val store = CompanionCredentialStore(context)
        val target = store.find(deviceId) ?: return failure("pairingExpired")
        val network = CompanionNetwork(context).selectLanEndpoint()?.network
        val response = try {
            CompanionClient(target.spkiPin, network).get(target.baseUrl(), path, target.token)
        } catch (e: Exception) {
            return failure(if (isIdentityMismatch(e)) "identityChanged" else "appUnavailable")
        }
        if (response.code != 200) return failure(mappedErrorCode(response.body))
        val data = parseObject(response.body) ?: return failure("appUnavailable")
        store.touch(deviceId)
        if (!target.named) adoptPeerName(store, target, network)
        return mapOf("ok" to true, "data" to data)
    }

    private fun adoptPeerName(
        store: CompanionCredentialStore,
        target: CompanionTarget,
        network: android.net.Network?,
    ) {
        runCatching {
            val response = CompanionClient(target.spkiPin, network)
                .get(target.baseUrl(), "/v1/hello", target.token)
            if (response.code != 200) return
            JsonParser.parseString(response.body).asJsonObject.get("name")?.asString
                ?.takeIf { it.isNotBlank() }
                ?.let { store.adoptName(target.deviceId, it) }
        }
    }

    private fun command(
        context: Context,
        deviceId: String?,
        kind: String?,
        arguments: Map<String, Any?>,
    ): Map<String, Any?> {
        if (deviceId == null || kind == null) return failure("invalidInput")
        val store = CompanionCredentialStore(context)
        val target = store.find(deviceId) ?: return failure("pairingExpired")
        val network = CompanionNetwork(context).selectLanEndpoint()?.network
        val body = gson.toJson(
            mapOf(
                "requestId" to randomB64(16),
                "kind" to kind,
                "arguments" to arguments,
            ),
        )
        val response = try {
            CompanionClient(target.spkiPin, network).postCommand(target.baseUrl(), target.token, body)
        } catch (e: Exception) {
            return failure(if (isIdentityMismatch(e)) "identityChanged" else "appUnavailable")
        }
        if (response.code != 200) return failure(mappedErrorCode(response.body))
        val data = parseObject(response.body) ?: return failure("appUnavailable")
        store.touch(deviceId)
        return mapOf("ok" to true, "data" to data)
    }

    private fun forget(context: Context, deviceId: String?): Map<String, Any?> {
        if (deviceId == null) return failure("invalidInput")
        val store = CompanionCredentialStore(context)
        val target = store.find(deviceId)
        if (target != null && target.active) {
            val network = CompanionNetwork(context).selectLanEndpoint()?.network
            runCatching {
                CompanionClient(target.spkiPin, network).revokeSelf(target.baseUrl(), target.token)
            }
        }
        store.remove(deviceId)
        return mapOf("ok" to true)
    }

    private fun asyncResult(result: MethodChannel.Result, block: () -> Map<String, Any?>) {
        GlobalState.launch {
            // GlobalState is a SupervisorJob with no exception handler: a throw here would swallow
            // the reply and hang the Dart Future forever, so every path must resolve to a map.
            val outcome = withContext(Dispatchers.IO) {
                try {
                    block()
                } catch (_: Exception) {
                    failure("appUnavailable")
                }
            }
            withContext(Dispatchers.Main) { result.success(outcome) }
        }
    }

    private fun parseObject(body: String): Map<String, Any?>? = try {
        @Suppress("UNCHECKED_CAST")
        gson.fromJson(JsonParser.parseString(body).asJsonObject, Map::class.java) as Map<String, Any?>
    } catch (_: Exception) {
        null
    }

    private fun errorCode(body: String): String = try {
        JsonParser.parseString(body).asJsonObject
            .getAsJsonObject("error").get("code").asString
    } catch (_: Exception) {
        "outcomeUnknown"
    }

    // Wrong-token (unauthorized) and revoked-pairing (forbidden) both mean the TV no longer trusts us.
    private fun mappedErrorCode(body: String): String = when (val code = errorCode(body)) {
        "unauthorized", "forbidden" -> "accessRevoked"
        else -> code
    }

    // OkHttp wraps PinnedTrustManager's CertificateException in an SSLHandshakeException, so the
    // "identityChanged" marker can sit anywhere on the cause chain.
    private fun isIdentityMismatch(error: Throwable): Boolean {
        var cause: Throwable? = error
        while (cause != null) {
            if (cause.message == "identityChanged") return true
            cause = cause.cause
        }
        return false
    }

    private fun rename(
        context: Context,
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        val deviceId = call.argument<String>("deviceId")
        val name = call.argument<String>("name")?.let(::sanitizeName)
        if (deviceId == null || name == null) {
            result.error("invalidInput", null, null)
            return
        }
        if (CompanionCredentialStore(context).rename(deviceId, name)) {
            result.success(mapOf("ok" to true))
        } else {
            result.error("pairingExpired", null, null)
        }
    }

    private fun sanitizeName(value: String): String? {
        val stripped = value.filter { it.code >= 0x20 && it.code != 0x7F && !it.isBidiControl() }
        val trimmed = stripped.trim()
        return trimmed.takeIf { it.isNotEmpty() && it.length <= MAX_NAME_CHARS }
    }

    private fun Char.isBidiControl(): Boolean =
        code in 0x202A..0x202E || code in 0x2066..0x2069 || code == 0x200E || code == 0x200F

    private fun failure(code: String): Map<String, Any?> = mapOf("ok" to false, "code" to code)

    private fun targetMap(view: CompanionTargetView): Map<String, Any?> = mapOf(
        "deviceId" to view.deviceId,
        "clientName" to view.clientName,
        "host" to view.host,
        "port" to view.port,
        "active" to view.active,
        "lastSeenAtMs" to view.lastSeenAtMs,
    )

    private fun CompanionTarget.baseUrl(): String = "https://$host:$port"

    private fun randomB64(bytes: Int): String =
        java.util.Base64.getUrlEncoder().withoutPadding()
            .encodeToString(ByteArray(bytes).also(random::nextBytes))

    companion object {
        private const val CHANNEL = "com.reclash/companion_client"
        private const val MAX_NAME_CHARS = 64
    }
}
