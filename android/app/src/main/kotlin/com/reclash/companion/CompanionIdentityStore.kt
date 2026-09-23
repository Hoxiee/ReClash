package com.reclash.companion

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.math.BigInteger
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.MessageDigest
import java.security.PrivateKey
import java.security.cert.X509Certificate
import java.util.Date
import javax.net.ssl.KeyManagerFactory
import javax.net.ssl.SSLContext
import javax.net.ssl.SSLServerSocketFactory

// Non-exportable EC P-256 key in AndroidKeyStore. GATE C proves an embedded server can terminate
// TLS against it, since such a key cannot be loaded into a Dart SecurityContext as PEM.
internal class CompanionIdentityStore(
    private val alias: String = DEFAULT_ALIAS,
) {
    // Deferred so merely constructing the store touches no provider: the JVM router tests build a
    // server without a keystore, and the real identity is only ever needed at startSecure().
    private val keyStore: KeyStore by lazy {
        KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
    }

    fun ensureIdentity(): CompanionIdentity {
        if (!keyStore.containsAlias(alias)) {
            generateKeyPair()
        }
        val certificate = keyStore.getCertificate(alias) as X509Certificate
        val privateKey = keyStore.getKey(alias, null) as PrivateKey
        return CompanionIdentity(certificate, privateKey, spkiPin(certificate))
    }

    fun clearIdentity() {
        if (keyStore.containsAlias(alias)) {
            keyStore.deleteEntry(alias)
        }
    }

    fun serverSocketFactory(): SSLServerSocketFactory {
        ensureIdentity()
        val keyManagerFactory = KeyManagerFactory.getInstance(
            KeyManagerFactory.getDefaultAlgorithm(),
        ).apply { init(keyStore, null) }
        return SSLContext.getInstance("TLS").apply {
            init(keyManagerFactory.keyManagers, null, null)
        }.serverSocketFactory
    }

    private fun generateKeyPair() {
        val now = System.currentTimeMillis()
        val spec = KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_SIGN)
            .setAlgorithmParameterSpec(java.security.spec.ECGenParameterSpec("secp256r1"))
            // Conscrypt drives digest choice during the TLS handshake (TLS 1.3 EC signatures can be
            // raw), so the key must authorise NONE plus the SHA family, not SHA-256 alone.
            .setDigests(
                KeyProperties.DIGEST_NONE,
                KeyProperties.DIGEST_SHA256,
                KeyProperties.DIGEST_SHA384,
                KeyProperties.DIGEST_SHA512,
            )
            .setCertificateSubject(javax.security.auth.x500.X500Principal("CN=ReClash Companion"))
            .setCertificateSerialNumber(BigInteger.valueOf(now))
            .setCertificateNotBefore(Date(now - CLOCK_SKEW_MS))
            .setCertificateNotAfter(Date(now + VALIDITY_MS))
            .build()
        KeyPairGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_EC,
            ANDROID_KEYSTORE,
        ).apply {
            initialize(spec)
            generateKeyPair()
        }
    }

    companion object {
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
        private const val DEFAULT_ALIAS = "reclash_companion_tls"
        private const val CLOCK_SKEW_MS = 5 * 60 * 1000L
        private const val VALIDITY_MS = 20L * 365 * 24 * 60 * 60 * 1000

        fun spkiPin(certificate: X509Certificate): String {
            val spki = certificate.publicKey.encoded
            val digest = MessageDigest.getInstance("SHA-256").digest(spki)
            return android.util.Base64.encodeToString(
                digest,
                android.util.Base64.URL_SAFE or android.util.Base64.NO_PADDING or
                    android.util.Base64.NO_WRAP,
            )
        }
    }
}

internal data class CompanionIdentity(
    val certificate: X509Certificate,
    val privateKey: PrivateKey,
    val spkiPin: String,
)
