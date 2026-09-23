package com.reclash.companion

import android.content.Context
import java.security.MessageDigest
import java.security.SecureRandom

// On-device closure of GATE C (Keystore TLS + pin) and GATE D (LAN selection). Boots the real
// router on the selected LAN IPv4 with a pre-seeded trusted client, then a pinned client calls
// /v1/hello end to end. A mismatched pin and a wrong token must both fail — that negative result is
// as much the gate as the 200.
internal class CompanionGateRunner(private val context: Context) {

    fun run(): Map<String, Any?> {
        val identity = CompanionIdentityStore()
        val pin = identity.ensureIdentity().spkiPin
        val endpoint = CompanionNetwork(context).selectLanEndpoint()
            ?: return mapOf("ok" to false, "stage" to "lan", "detail" to "no physical LAN IPv4")

        val token = randomToken()
        val trustStore = InMemoryTrustStore().apply {
            put(
                CompanionTrustedClient(
                    clientId = "gate",
                    clientName = "gate",
                    tokenHash = MessageDigest.getInstance("SHA-256").digest(token.toByteArray()),
                    scopes = COMPANION_DEFAULT_SCOPES,
                    createdAtMs = 0,
                    lastSeenAtMs = 0,
                ),
            )
        }
        val pairing = CompanionPairing(trustStore, System::currentTimeMillis)
        val port = freePort()
        val server = CompanionServer(
            hostname = endpoint.ipv4,
            port = port,
            identity = identity,
            trustStore = trustStore,
            pairing = pairing,
            serverEpoch = "gate",
            helloProvider = { mapOf("protocol" to 1, "appReady" to true) },
        )
        return try {
            server.startSecure()
            val base = "https://${endpoint.ipv4}:$port"
            val client = CompanionClient(pin, endpoint.network)
            val authorized = client.hello(base, token)
            val rejectedBadToken = client.hello(base, randomToken())
            val rejectedBadPin = runCatching {
                CompanionClient(WRONG_PIN, endpoint.network).hello(base, token)
            }.isFailure
            mapOf(
                "ok" to (authorized == 200 && rejectedBadToken == 401 && rejectedBadPin),
                "ipv4" to endpoint.ipv4,
                "port" to port,
                "spkiPin" to pin,
                "authorizedCode" to authorized,
                "badTokenCode" to rejectedBadToken,
                "badPinRejected" to rejectedBadPin,
            )
        } catch (t: Throwable) {
            mapOf("ok" to false, "stage" to "tls", "detail" to (t.message ?: t.javaClass.simpleName))
        } finally {
            server.stop()
        }
    }

    private fun randomToken(): String {
        val bytes = ByteArray(32).also(SecureRandom()::nextBytes)
        return android.util.Base64.encodeToString(
            bytes,
            android.util.Base64.URL_SAFE or android.util.Base64.NO_PADDING or
                android.util.Base64.NO_WRAP,
        )
    }

    private fun freePort(): Int = java.net.ServerSocket(0).use { it.localPort }

    private class InMemoryTrustStore : CompanionTrustStore {
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

    companion object {
        private const val WRONG_PIN = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    }
}
