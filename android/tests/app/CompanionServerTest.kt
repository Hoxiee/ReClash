package com.reclash.companion

import com.google.gson.Gson
import com.google.gson.JsonParser
import fi.iki.elonen.NanoHTTPD
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.security.MessageDigest
import java.security.SecureRandom
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

// Router-level security matrix for CompanionServer on the JVM: authorization, scope enforcement,
// serverEpoch conflict, pre-parse body rejection and name sanitization, plus the command replay
// ledger through the real handler. No device, no TLS — serve() is driven with a fake session.
class CompanionServerTest {
    private val gson = Gson()
    private val trustStore = FakeTrustStore()
    private val pairing = CompanionPairing(trustStore, { 1_000L }, SecureRandom().apply { setSeed(7) })

    private fun server(bridge: CompanionEngineBridge = OkBridge()): CompanionServer =
        CompanionServer(
            hostname = "192.168.1.2",
            port = 0,
            identity = CompanionIdentityStore(),
            trustStore = trustStore,
            pairing = pairing,
            serverEpoch = "epoch-1",
            helloProvider = { mapOf("name" to "TV", "capabilities" to it.scopes) },
            bridge = bridge,
            commands = CompanionCommandRegistry(),
        )

    private fun trust(token: String, scopes: List<String> = COMPANION_DEFAULT_SCOPES): String {
        trustStore.put(
            CompanionTrustedClient(
                clientId = "c1",
                clientName = "Phone",
                tokenHash = sha256(token),
                scopes = scopes,
                createdAtMs = 0,
                lastSeenAtMs = 0,
            ),
        )
        return token
    }

    @Test
    fun `a protected route without a token is unauthorized`() {
        val response = server().serve(get("/v1/state"))
        assertEquals(401, response.status())
        assertEquals("unauthorized", response.errorCode())
    }

    @Test
    fun `a malformed authorization header without the bearer prefix is unauthorized`() {
        val response = server().serve(get("/v1/state", headers = mapOf("authorization" to "token-only")))
        assertEquals(401, response.status())
    }

    @Test
    fun `an empty bearer token is unauthorized`() {
        val response = server().serve(get("/v1/state", headers = mapOf("authorization" to "Bearer ")))
        assertEquals(401, response.status())
    }

    @Test
    fun `a valid token reads state`() {
        val token = trust("tok-1")
        val response = server().serve(get("/v1/state", token = token))
        assertEquals(200, response.status())
        assertEquals("on", response.json().asJsonObject.get("value").asString)
    }

    @Test
    fun `a token missing the scope is forbidden`() {
        val token = trust("tok-1", scopes = listOf("state.read"))
        val response = server().serve(
            post(
                "/v1/commands",
                body = gson.toJson(mapOf("requestId" to "r1", "kind" to "connection.setRunning")),
                token = token,
            ),
        )
        assertEquals(403, response.status())
        assertEquals("forbidden", response.errorCode())
    }

    @Test
    fun `a command with a stale serverEpoch is a conflict`() {
        val token = trust("tok-1")
        val response = server().serve(
            post(
                "/v1/commands",
                body = gson.toJson(
                    mapOf("requestId" to "r1", "kind" to "connection.setRunning", "serverEpoch" to "old"),
                ),
                token = token,
            ),
        )
        assertEquals(409, response.status())
        assertEquals("staleGeneration", response.errorCode())
    }

    @Test
    fun `an unknown command kind is invalid input`() {
        val token = trust("tok-1")
        val response = server().serve(
            post(
                "/v1/commands",
                body = gson.toJson(mapOf("requestId" to "r1", "kind" to "does.notExist")),
                token = token,
            ),
        )
        assertEquals(400, response.status())
        assertEquals("invalidInput", response.errorCode())
    }

    @Test
    fun `profiles select routes to the activate scope`() {
        val token = trust("tok-1")
        val response = server().serve(
            post(
                "/v1/commands",
                body = gson.toJson(
                    mapOf("requestId" to "r1", "kind" to "profiles.select", "arguments" to mapOf("id" to 3)),
                ),
                token = token,
            ),
        )
        assertEquals(200, response.status())
    }

    @Test
    fun `a chunked request is refused before parsing`() {
        val token = trust("tok-1")
        val response = server().serve(
            post("/v1/commands", body = "{}", token = token, headers = mapOf("transfer-encoding" to "chunked")),
        )
        assertEquals(413, response.status())
        assertEquals("invalidInput", response.errorCode())
    }

    @Test
    fun `a multipart body is refused before parsing`() {
        val token = trust("tok-1")
        val response = server().serve(
            post("/v1/commands", body = "{}", token = token, headers = mapOf("content-type" to "multipart/form-data")),
        )
        assertEquals(413, response.status())
    }

    @Test
    fun `an oversize body is refused`() {
        val token = trust("tok-1")
        val huge = "x".repeat(70 * 1024)
        val response = server().serve(post("/v1/commands", body = huge, token = token))
        assertEquals(413, response.status())
    }

    @Test
    fun `a retried command replays the receipt without re-running the effect`() {
        val token = trust("tok-1")
        val bridge = CountingBridge()
        val srv = server(bridge)
        val body = gson.toJson(mapOf("requestId" to "r1", "kind" to "connection.setRunning"))
        val first = srv.serve(post("/v1/commands", body = body, token = token))
        val second = srv.serve(post("/v1/commands", body = body, token = token))
        assertEquals(200, first.status())
        assertEquals(200, second.status())
        assertEquals(1, bridge.commandRuns)
    }

    @Test
    fun `pairing submit strips bidi control characters from the client name`() {
        val window = pairing.openWindow()
        val body = gson.toJson(
            mapOf(
                "pairingSecret" to window.secret,
                "clientId" to "c1",
                "clientName" to "Phone‮evil",
                "clientToken" to "tok-1",
            ),
        )
        val response = server().serve(post("/v1/pairings", body = body))
        assertEquals(202, response.status())
        assertTrue(pairing.approvePending())
        val stored = trustStore.list().single().clientName
        assertFalse(stored.contains('‮'))
    }

    @Test
    fun `an unknown route is not found`() {
        val response = server().serve(get("/v1/nope", token = trust("tok-1")))
        assertEquals(404, response.status())
    }

    private fun sha256(value: String) =
        MessageDigest.getInstance("SHA-256").digest(value.toByteArray(Charsets.UTF_8))

    private fun get(uri: String, token: String? = null, headers: Map<String, String> = emptyMap()) =
        FakeSession(NanoHTTPD.Method.GET, uri, headers = authHeaders(token, headers))

    private fun post(
        uri: String,
        body: String,
        token: String? = null,
        headers: Map<String, String> = emptyMap(),
    ) = FakeSession(
        NanoHTTPD.Method.POST,
        uri,
        body = body,
        headers = authHeaders(token, headers) + ("content-length" to body.toByteArray().size.toString()),
    )

    private fun authHeaders(token: String?, extra: Map<String, String>): Map<String, String> =
        buildMap {
            if (token != null) put("authorization", "Bearer $token")
            putAll(extra)
        }

    private fun NanoHTTPD.Response.status(): Int = this.status.requestStatus
    private fun NanoHTTPD.Response.bodyText(): String = data.readBytes().toString(Charsets.UTF_8)
    private fun NanoHTTPD.Response.json() = JsonParser.parseString(bodyText())
    private fun NanoHTTPD.Response.errorCode(): String? =
        JsonParser.parseString(bodyText()).asJsonObject.getAsJsonObject("error")?.get("code")?.asString

    private open class OkBridge : CompanionEngineBridge() {
        override fun call(method: String, arguments: Any?): CompanionBridgeResult = when (method) {
            "command" -> CompanionBridgeResult.Ok(mapOf("status" to "succeeded", "effectState" to "applied"))
            else -> CompanionBridgeResult.Ok("on")
        }
    }

    private class CountingBridge : OkBridge() {
        var commandRuns = 0
        override fun call(method: String, arguments: Any?): CompanionBridgeResult {
            if (method == "command") commandRuns++
            return super.call(method, arguments)
        }
    }

    private class FakeSession(
        private val method: NanoHTTPD.Method,
        private val uri: String,
        private val body: String = "",
        private val headers: Map<String, String> = emptyMap(),
    ) : NanoHTTPD.IHTTPSession {
        override fun execute() {}
        override fun getCookies(): NanoHTTPD.CookieHandler? = null
        override fun getHeaders(): MutableMap<String, String> = headers.toMutableMap()
        override fun getInputStream(): InputStream = ByteArrayInputStream(body.toByteArray())
        override fun getMethod(): NanoHTTPD.Method = method
        override fun getParms(): MutableMap<String, String> = mutableMapOf()
        override fun getParameters(): MutableMap<String, MutableList<String>> = mutableMapOf()
        override fun getQueryParameterString(): String = ""
        override fun getUri(): String = uri
        override fun parseBody(files: MutableMap<String, String>) {
            files["postData"] = body
        }
        override fun getRemoteIpAddress(): String = "192.168.1.9"
        override fun getRemoteHostName(): String = "phone"
    }

    private class FakeTrustStore : CompanionTrustStore {
        private val clients = LinkedHashMap<String, CompanionTrustedClient>()
        override fun list() = clients.values.toList()
        override fun find(clientId: String) = clients[clientId]
        override fun matchToken(token: String): CompanionTrustedClient? {
            val hash = MessageDigest.getInstance("SHA-256").digest(token.toByteArray())
            return clients.values.firstOrNull { MessageDigest.isEqual(hash, it.tokenHash) }
        }
        override fun put(client: CompanionTrustedClient): Boolean {
            clients[client.clientId] = client
            return true
        }
        override fun remove(clientId: String) = clients.remove(clientId) != null
        override fun clear() = clients.clear()
        override fun count() = clients.size
    }
}
