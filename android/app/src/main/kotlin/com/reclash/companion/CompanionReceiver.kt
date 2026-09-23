package com.reclash.companion

import android.content.Context
import java.io.File
import java.security.SecureRandom

// TV side owner: identity, trust registry, pairing FSM and the HTTPS listener bound to the physical
// LAN IPv4. It never touches the VPN binding (I02). The pairing window opens only on a local TV
// action, and approval is a local confirmation — the phone can never approve itself remotely.
internal class CompanionReceiver private constructor(context: Context) {
    private val appContext = context.applicationContext
    private val identity = CompanionIdentityStore()
    private val trustStore = CompanionFileTrustStore(File(receiverDir(appContext), "pairings.json"))
    private val pairing = CompanionPairing(trustStore, System::currentTimeMillis)
    private val deviceId = loadOrCreateDeviceId(appContext)
    private var server: CompanionServer? = null
    private var endpoint: CompanionLanEndpoint? = null
    private var serverEpoch = randomB64(16)

    fun isRunning(): Boolean = server != null

    @Synchronized
    fun enable(): CompanionEnableResult {
        if (server != null) {
            val active = endpoint ?: return CompanionEnableResult.Error("appUnavailable")
            return CompanionEnableResult.Running(deviceId, active.ipv4, server!!.listeningPort)
        }
        val selected = CompanionNetwork(appContext).selectLanEndpoint()
            ?: return CompanionEnableResult.Error("noLan")
        serverEpoch = randomB64(16)
        val started = CompanionServer(
            hostname = selected.ipv4,
            port = 0,
            identity = identity,
            trustStore = trustStore,
            pairing = pairing,
            serverEpoch = serverEpoch,
            helloProvider = ::hello,
        )
        return try {
            started.startSecure()
            server = started
            endpoint = selected
            CompanionEnableResult.Running(deviceId, selected.ipv4, started.listeningPort)
        } catch (t: Throwable) {
            CompanionEnableResult.Error(t.message ?: "tls")
        }
    }

    @Synchronized
    fun disable() {
        pairing.cancelWindow()
        server?.stop()
        server = null
        endpoint = null
    }

    @Synchronized
    fun openPairingWindow(): Map<String, Any?>? {
        val active = server ?: return null
        val lan = endpoint ?: return null
        val window = pairing.openWindow()
        return mapOf(
            "deviceId" to deviceId,
            "host" to lan.ipv4,
            "port" to active.listeningPort,
            "spkiPin" to identity.ensureIdentity().spkiPin,
            "pairingSecret" to window.secret,
            "expiresInMs" to window.expiresInMs,
        )
    }

    @Synchronized
    fun cancelPairingWindow() = pairing.cancelWindow()

    @Synchronized
    fun pendingPairing(): Map<String, Any?>? {
        val summary = pairing.pendingSummary() ?: return null
        return mapOf(
            "clientId" to summary.clientId,
            "clientName" to summary.clientName,
            "confirmationCode" to summary.confirmationCode,
        )
    }

    @Synchronized
    fun approvePending(): Boolean = pairing.approvePending()

    @Synchronized
    fun rejectPending() = pairing.cancelWindow()

    @Synchronized
    fun trustedClients(): List<Map<String, Any?>> = trustStore.list().map {
        mapOf(
            "clientId" to it.clientId,
            "clientName" to it.clientName,
            "createdAtMs" to it.createdAtMs,
            "lastSeenAtMs" to it.lastSeenAtMs,
        )
    }

    @Synchronized
    fun revokeClient(clientId: String): Boolean = trustStore.remove(clientId)

    // Local-only identity reset (§10.3): drops every pairing and the TLS key, forcing re-pair.
    @Synchronized
    fun resetIdentity() {
        disable()
        trustStore.clear()
        identity.clearIdentity()
    }

    private fun hello(client: CompanionTrustedClient): Map<String, Any?> = mapOf(
        "protocol" to 1,
        "deviceId" to deviceId,
        "name" to (android.os.Build.MODEL ?: "ReClash"),
        "appReady" to true,
        "capabilities" to client.scopes,
    )

    companion object {
        @Volatile
        private var instance: CompanionReceiver? = null

        fun get(context: Context): CompanionReceiver =
            instance ?: synchronized(this) {
                instance ?: CompanionReceiver(context).also { instance = it }
            }

        private fun receiverDir(context: Context): File =
            File(context.filesDir, "companion").apply { mkdirs() }

        private fun loadOrCreateDeviceId(context: Context): String {
            val file = File(receiverDir(context), "device_id")
            if (file.exists()) {
                val existing = file.readText().trim()
                if (existing.isNotEmpty()) return existing
            }
            val fresh = randomB64(16)
            file.writeText(fresh)
            return fresh
        }

        private fun randomB64(bytes: Int): String =
            java.util.Base64.getUrlEncoder().withoutPadding()
                .encodeToString(ByteArray(bytes).also(SecureRandom()::nextBytes))
    }
}

internal sealed class CompanionEnableResult {
    data class Running(val deviceId: String, val host: String, val port: Int) : CompanionEnableResult()
    data class Error(val reason: String) : CompanionEnableResult()
}
