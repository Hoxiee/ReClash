package com.reclash.companion

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import fi.iki.elonen.NanoHTTPD

// HTTPS router terminating TLS against the AndroidKeyStore identity (§11/§13). Binds a concrete LAN
// IPv4, never 0.0.0.0 nor the loopback controller. Only pairing endpoints answer unauthenticated,
// and only inside an open window; every other route needs a trusted bearer token. Bodies are
// bounded and Transfer-Encoding/multipart POSTs refused before any parsing (S13). Errors carry an
// allowlisted machine code, never a raw exception, URL or header (S14).
internal class CompanionServer(
    hostname: String,
    port: Int,
    private val identity: CompanionIdentityStore,
    private val trustStore: CompanionTrustStore,
    private val pairing: CompanionPairing,
    private val serverEpoch: String,
    private val helloProvider: (CompanionTrustedClient) -> Map<String, Any?>,
    private val bridge: CompanionEngineBridge = CompanionEngineBridge(),
    private val commands: CompanionCommandRegistry = CompanionCommandRegistry(),
) : NanoHTTPD(hostname, port) {
    private val gson = Gson()

    fun startSecure() {
        makeSecure(identity.serverSocketFactory(), null)
        start(HANDSHAKE_TIMEOUT_MS, false)
    }

    override fun serve(session: IHTTPSession): Response {
        return try {
            route(session)
        } catch (_: BodyTooLargeException) {
            error(Response.Status.PAYLOAD_TOO_LARGE, "invalidInput")
        } catch (_: Exception) {
            error(Response.Status.INTERNAL_ERROR, "internalError")
        }
    }

    private fun route(session: IHTTPSession): Response {
        val uri = session.uri
        val method = session.method
        return when {
            method == Method.POST && uri == "/v1/pairings" -> handlePairingSubmit(session)
            method == Method.GET && uri.startsWith("/v1/pairings/") ->
                handlePairingStatus(session, uri.removePrefix("/v1/pairings/"))
            method == Method.DELETE && uri == "/v1/pairings/self" -> handleRevokeSelf(session)
            method == Method.GET && uri == "/v1/hello" -> handleHello(session)
            method == Method.GET && uri == "/v1/state" -> handleRead(session, "state.read", "readState")
            method == Method.GET && uri == "/v1/profiles" -> handleRead(session, "profiles.read", "readProfiles")
            method == Method.GET && uri == "/v1/groups" -> handleRead(session, "state.read", "readGroups")
            method == Method.POST && uri == "/v1/commands" -> handleCommand(session)
            else -> error(Response.Status.NOT_FOUND, "resourceNotFound")
        }
    }

    private fun handleRead(session: IHTTPSession, scope: String, method: String): Response {
        val client = authenticate(session) ?: return error(Response.Status.UNAUTHORIZED, "unauthorized")
        if (!client.scopes.contains(scope)) return error(Response.Status.FORBIDDEN, "forbidden")
        return when (val outcome = bridge.call(method, null)) {
            is CompanionBridgeResult.Ok -> json(Response.Status.OK, wrap(outcome.value))
            is CompanionBridgeResult.Failed -> errorForCode(outcome.code)
            CompanionBridgeResult.Unreachable -> error(Response.Status.SERVICE_UNAVAILABLE, "appUnavailable")
        }
    }

    private fun handleCommand(session: IHTTPSession): Response {
        val client = authenticate(session) ?: return error(Response.Status.UNAUTHORIZED, "unauthorized")
        val body = readJsonBody(session) ?: return error(Response.Status.BAD_REQUEST, "invalidInput")
        val requestId = body.stringOrNull("requestId")
        val kind = body.stringOrNull("kind")
        val epoch = body.stringOrNull("serverEpoch")
        if (requestId == null || kind == null) return error(Response.Status.BAD_REQUEST, "invalidInput")
        if (epoch != null && epoch != serverEpoch) return error(Response.Status.CONFLICT, "staleGeneration")
        val scope = scopeForKind(kind) ?: return error(Response.Status.BAD_REQUEST, "invalidInput")
        if (!client.scopes.contains(scope)) return error(Response.Status.FORBIDDEN, "forbidden")

        val arguments = if (body.has("arguments") && body.get("arguments").isJsonObject) {
            gson.fromJson(body.getAsJsonObject("arguments"), Map::class.java)
        } else {
            emptyMap<String, Any?>()
        }
        val payloadHash = (kind to arguments).hashCode()
        val outcome = commands.resolve(client.clientId, serverEpoch, requestId, payloadHash) {
            when (val bridged = bridge.call("command", mapOf("kind" to kind, "arguments" to arguments))) {
                is CompanionBridgeResult.Ok -> wrap(bridged.value)
                is CompanionBridgeResult.Failed ->
                    mapOf("status" to "failed", "effectState" to "configured", "error" to bridged.code)
                CompanionBridgeResult.Unreachable ->
                    mapOf("status" to "outcomeUnknown", "effectState" to "configured")
            }
        }
        return when (outcome) {
            is CommandOutcome.Fresh -> json(Response.Status.OK, outcome.result + ("requestId" to requestId))
            is CommandOutcome.Replay -> json(Response.Status.OK, outcome.result + ("requestId" to requestId))
            CommandOutcome.Conflict -> error(Response.Status.CONFLICT, "requestConflict")
        }
    }

    private fun scopeForKind(kind: String): String? = when (kind) {
        "connection.setRunning" -> "connection.setRunning"
        "groups.select", "settings.setOutboundMode" -> "groups.select"
        "profiles.select" -> "profiles.activate"
        "profiles.importUrl", "profiles.update", "profiles.updateCurrent" -> "profiles.importUrl"
        else -> null
    }

    @Suppress("UNCHECKED_CAST")
    private fun wrap(value: Any?): Map<String, Any?> = when (value) {
        is Map<*, *> -> value as Map<String, Any?>
        is List<*> -> mapOf("items" to value)
        else -> mapOf("value" to value)
    }

    private fun handlePairingSubmit(session: IHTTPSession): Response {
        val body = readJsonBody(session) ?: return error(Response.Status.BAD_REQUEST, "invalidInput")
        val secret = body.stringOrNull("pairingSecret")
        val clientId = body.stringOrNull("clientId")?.let(::sanitizeName)
        val clientName = body.stringOrNull("clientName")?.let(::sanitizeName)
        val clientToken = body.stringOrNull("clientToken")
        if (secret == null || clientId == null || clientName == null || clientToken == null) {
            return error(Response.Status.BAD_REQUEST, "invalidInput")
        }
        return when (val result = pairing.submitPairing(secret, clientId, clientName, clientToken)) {
            is PairingSubmitResult.Accepted -> json(
                acceptedStatus(),
                mapOf(
                    "pairingId" to result.pairingId,
                    "confirmationCode" to result.confirmationCode,
                    "expiresInMs" to result.expiresInMs,
                ),
            )
            is PairingSubmitResult.Rejected -> errorForCode(result.code)
        }
    }

    private fun handlePairingStatus(session: IHTTPSession, pairingId: String): Response {
        val token = bearer(session) ?: return error(Response.Status.UNAUTHORIZED, "unauthorized")
        return when (val result = pairing.pollStatus(pairingId, token)) {
            is PairingStatusResult.Status -> {
                val payload = mutableMapOf<String, Any?>("phase" to result.phase)
                if (result.confirmationCode != null) {
                    payload["confirmationCode"] = result.confirmationCode
                }
                json(Response.Status.OK, payload)
            }
            is PairingStatusResult.Rejected -> errorForCode(result.code)
        }
    }

    private fun handleRevokeSelf(session: IHTTPSession): Response {
        val client = authenticate(session) ?: return error(Response.Status.UNAUTHORIZED, "unauthorized")
        trustStore.remove(client.clientId)
        return json(Response.Status.OK, mapOf("revoked" to true))
    }

    private fun handleHello(session: IHTTPSession): Response {
        val client = authenticate(session) ?: return error(Response.Status.UNAUTHORIZED, "unauthorized")
        return json(Response.Status.OK, helloProvider(client) + ("serverEpoch" to serverEpoch))
    }

    private fun authenticate(session: IHTTPSession): CompanionTrustedClient? {
        val token = bearer(session) ?: return null
        return trustStore.matchToken(token)
    }

    private fun bearer(session: IHTTPSession): String? {
        val header = session.headers["authorization"] ?: return null
        val token = header.removePrefix("Bearer ").trim()
        return token.takeIf { it.isNotEmpty() && it != header }
    }

    private fun readJsonBody(session: IHTTPSession): JsonObject? {
        if (session.headers["transfer-encoding"] != null) throw BodyTooLargeException()
        val length = session.headers["content-length"]?.toLongOrNull() ?: return null
        if (length > MAX_BODY_BYTES) throw BodyTooLargeException()
        val contentType = session.headers["content-type"].orEmpty()
        if (contentType.contains("multipart", ignoreCase = true)) throw BodyTooLargeException()
        val files = HashMap<String, String>()
        session.parseBody(files)
        val raw = files["postData"] ?: return null
        if (raw.toByteArray(Charsets.UTF_8).size > MAX_BODY_BYTES) throw BodyTooLargeException()
        return try {
            JsonParser.parseString(raw).asJsonObject
        } catch (_: Exception) {
            null
        }
    }

    private fun sanitizeName(value: String): String? {
        val stripped = value.filter { it.code >= 0x20 && it.code != 0x7F && !it.isBidiControl() }
        val trimmed = stripped.trim()
        return trimmed.takeIf { it.isNotEmpty() && it.length <= MAX_NAME_CHARS }
    }

    private fun Char.isBidiControl(): Boolean =
        code in 0x202A..0x202E || code in 0x2066..0x2069 || code == 0x200E || code == 0x200F

    private fun JsonObject.stringOrNull(key: String): String? =
        if (has(key) && get(key).isJsonPrimitive) get(key).asString else null

    private fun acceptedStatus(): Response.IStatus = object : Response.IStatus {
        override fun getDescription() = "202 Accepted"
        override fun getRequestStatus() = 202
    }

    private fun json(status: Response.IStatus, payload: Map<String, Any?>): Response =
        newFixedLengthResponse(status, MIME_JSON, gson.toJson(payload))

    private fun error(status: Response.IStatus, code: String): Response =
        newFixedLengthResponse(
            status,
            MIME_JSON,
            gson.toJson(mapOf("error" to mapOf("code" to code, "retryable" to false))),
        )

    private fun errorForCode(code: String): Response = error(httpStatusFor(code), code)

    private fun httpStatusFor(code: String): Response.IStatus = when (code) {
        "invalidInput" -> Response.Status.BAD_REQUEST
        "unauthorized" -> Response.Status.UNAUTHORIZED
        "pairingRejected", "deviceLimit", "forbidden" -> Response.Status.FORBIDDEN
        "pairingExpired" -> Response.Status.NOT_FOUND
        "requestConflict", "staleGeneration" -> Response.Status.CONFLICT
        "busy" -> Response.Status.TOO_MANY_REQUESTS
        "appUnavailable" -> Response.Status.SERVICE_UNAVAILABLE
        "applyFailed", "internalError" -> Response.Status.INTERNAL_ERROR
        else -> Response.Status.INTERNAL_ERROR
    }

    private class BodyTooLargeException : Exception()

    companion object {
        private const val MIME_JSON = "application/json"
        private const val HANDSHAKE_TIMEOUT_MS = 5000
        private const val MAX_BODY_BYTES = 64 * 1024
        private const val MAX_NAME_CHARS = 64
    }
}
