package com.reclash.companion

import android.net.Network
import java.security.MessageDigest
import java.security.cert.X509Certificate
import javax.net.ssl.SSLContext
import javax.net.ssl.X509TrustManager
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

// Phone side of the pinned channel. Trust is the stored SPKI pin alone: the leaf is accepted only
// on a pin match, in the TLS handshake before any Authorization is sent (S03). A mismatch is
// identityChanged. Redirects are refused outright — a control API must never follow one (S15).
internal class CompanionClient(
    private val spkiPin: String,
    network: Network?,
) {
    private val client: OkHttpClient

    init {
        val trustManager = PinnedTrustManager(spkiPin)
        val sslContext = SSLContext.getInstance("TLS").apply {
            init(null, arrayOf(trustManager), null)
        }
        client = OkHttpClient.Builder()
            .sslSocketFactory(sslContext.socketFactory, trustManager)
            .hostnameVerifier { _, _ -> true }
            .followRedirects(false)
            .followSslRedirects(false)
            .connectTimeout(java.time.Duration.ofSeconds(3))
            // Above the engine bridge's own timeout: a command the TV is still applying must not
            // time out on the phone and provoke a retry that double-applies (a re-fetch on
            // profiles.update), since the phone sends a fresh requestId and no serverEpoch.
            .readTimeout(java.time.Duration.ofSeconds(12))
            .apply { if (network != null) socketFactory(network.socketFactory) }
            .build()
    }

    fun hello(baseUrl: String, token: String): Int {
        val request = Request.Builder()
            .url("$baseUrl/v1/hello")
            .header("Authorization", "Bearer $token")
            .build()
        return client.newCall(request).execute().use { it.code }
    }

    fun submitPairing(baseUrl: String, body: String): CompanionHttpResponse {
        val request = Request.Builder()
            .url("$baseUrl/v1/pairings")
            .post(body.toRequestBody(JSON))
            .build()
        return client.newCall(request).execute().use {
            CompanionHttpResponse(it.code, it.body?.string().orEmpty())
        }
    }

    fun pollPairing(baseUrl: String, pairingId: String, token: String): CompanionHttpResponse {
        val request = Request.Builder()
            .url("$baseUrl/v1/pairings/$pairingId")
            .header("Authorization", "Bearer $token")
            .build()
        return client.newCall(request).execute().use {
            CompanionHttpResponse(it.code, it.body?.string().orEmpty())
        }
    }

    fun get(baseUrl: String, path: String, token: String): CompanionHttpResponse {
        val request = Request.Builder()
            .url("$baseUrl$path")
            .header("Authorization", "Bearer $token")
            .build()
        return client.newCall(request).execute().use {
            CompanionHttpResponse(it.code, it.body?.string().orEmpty())
        }
    }

    fun postCommand(baseUrl: String, token: String, body: String): CompanionHttpResponse {
        val request = Request.Builder()
            .url("$baseUrl/v1/commands")
            .header("Authorization", "Bearer $token")
            .post(body.toRequestBody(JSON))
            .build()
        return client.newCall(request).execute().use {
            CompanionHttpResponse(it.code, it.body?.string().orEmpty())
        }
    }

    fun revokeSelf(baseUrl: String, token: String): Int {
        val request = Request.Builder()
            .url("$baseUrl/v1/pairings/self")
            .header("Authorization", "Bearer $token")
            .delete()
            .build()
        return client.newCall(request).execute().use { it.code }
    }

    private class PinnedTrustManager(private val expectedPin: String) : X509TrustManager {
        override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) =
            throw UnsupportedOperationException()

        override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {
            val leaf = chain.firstOrNull() ?: throw java.security.cert.CertificateException("empty")
            val digest = MessageDigest.getInstance("SHA-256").digest(leaf.publicKey.encoded)
            val pin = android.util.Base64.encodeToString(
                digest,
                android.util.Base64.URL_SAFE or android.util.Base64.NO_PADDING or
                    android.util.Base64.NO_WRAP,
            )
            if (!MessageDigest.isEqual(pin.toByteArray(), expectedPin.toByteArray())) {
                throw java.security.cert.CertificateException("identityChanged")
            }
        }

        override fun getAcceptedIssuers(): Array<X509Certificate> = emptyArray()
    }

    companion object {
        private val JSON = "application/json; charset=utf-8".toMediaType()
    }
}

internal data class CompanionHttpResponse(val code: Int, val body: String)
