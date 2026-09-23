package com.reclash.companion

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import com.google.gson.Gson
import java.io.File
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

// Phone registry (§10.3): per-TV bearer token sealed with AES-GCM under a non-exportable
// AndroidKeyStore key, never plaintext SharedPreferences nor the Drift/AppConfig backup. The token
// leaves only inside an Authorization header over pinned TLS (S14). File lives out of backup via
// data_extraction_rules.xml.
internal class CompanionCredentialStore(context: Context, private val maxTargets: Int = 16) {
    private val file = File(File(context.filesDir, "companion").apply { mkdirs() }, "targets.bin")
    private val gson = Gson()
    private val lock = Any()

    fun list(): List<CompanionTargetView> = synchronized(lock) {
        read().map {
            CompanionTargetView(it.deviceId, it.clientName, it.host, it.port, it.active, it.lastSeenAtMs)
        }
    }

    fun find(deviceId: String): CompanionTarget? = synchronized(lock) {
        read().firstOrNull { it.deviceId == deviceId }
    }

    fun put(target: CompanionTarget): Boolean = synchronized(lock) {
        val current = read().filterNot { it.deviceId == target.deviceId }
        if (current.size >= maxTargets) return false
        write(current + target)
        true
    }

    fun markActive(deviceId: String) = synchronized(lock) {
        write(read().map { if (it.deviceId == deviceId) it.copy(active = true) else it })
    }

    // Throttled so a visible panel polling every few seconds does not re-encrypt the store each read.
    fun touch(deviceId: String, atMs: Long = System.currentTimeMillis()) = synchronized(lock) {
        val current = read()
        val target = current.firstOrNull { it.deviceId == deviceId } ?: return
        if (atMs - (target.lastSeenAtMs ?: 0L) < TOUCH_THROTTLE_MS) return
        write(current.map { if (it.deviceId == deviceId) it.copy(lastSeenAtMs = atMs) else it })
    }

    fun rename(deviceId: String, name: String): Boolean = synchronized(lock) {
        val current = read()
        if (current.none { it.deviceId == deviceId }) return false
        write(current.map { if (it.deviceId == deviceId) it.copy(clientName = name, named = true) else it })
        true
    }

    fun adoptName(deviceId: String, name: String) = synchronized(lock) {
        write(
            read().map {
                if (it.deviceId == deviceId && !it.named) it.copy(clientName = name, named = true) else it
            },
        )
    }

    // Rediscovery landed a new address for the same pairing (DHCP/ephemeral-port change); keep the
    // token and pin, move only host:port so the next dial hits the peer without a re-pair.
    fun updateEndpoint(deviceId: String, host: String, port: Int): Boolean = synchronized(lock) {
        val current = read()
        if (current.none { it.deviceId == deviceId }) return false
        write(current.map { if (it.deviceId == deviceId) it.copy(host = host, port = port) else it })
        true
    }

    fun remove(deviceId: String): Boolean = synchronized(lock) {
        val current = read()
        val next = current.filterNot { it.deviceId == deviceId }
        if (next.size == current.size) return false
        write(next)
        true
    }

    private fun read(): List<CompanionTarget> {
        if (!file.exists()) return emptyList()
        return try {
            val blob = file.readBytes()
            if (blob.size <= GCM_IV_BYTES) return emptyList()
            val iv = blob.copyOfRange(0, GCM_IV_BYTES)
            val cipherText = blob.copyOfRange(GCM_IV_BYTES, blob.size)
            val cipher = Cipher.getInstance(TRANSFORMATION).apply {
                init(Cipher.DECRYPT_MODE, secretKey(), GCMParameterSpec(GCM_TAG_BITS, iv))
            }
            val json = String(cipher.doFinal(cipherText), Charsets.UTF_8)
            gson.fromJson(json, Array<CompanionTarget>::class.java).toList()
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun write(targets: List<CompanionTarget>) {
        val cipher = Cipher.getInstance(TRANSFORMATION).apply {
            init(Cipher.ENCRYPT_MODE, secretKey())
        }
        val cipherText = cipher.doFinal(gson.toJson(targets).toByteArray(Charsets.UTF_8))
        val tmp = File(file.parentFile, "${file.name}.tmp")
        tmp.writeBytes(cipher.iv + cipherText)
        if (!tmp.renameTo(file)) {
            file.delete()
            tmp.renameTo(file)
        }
    }

    private fun secretKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        (keyStore.getEntry(KEY_ALIAS, null) as? KeyStore.SecretKeyEntry)?.let { return it.secretKey }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        generator.init(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .build(),
        )
        return generator.generateKey()
    }

    companion object {
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
        private const val KEY_ALIAS = "reclash_companion_creds"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_IV_BYTES = 12
        private const val GCM_TAG_BITS = 128
        private const val TOUCH_THROTTLE_MS = 60_000L
    }
}

internal data class CompanionTarget(
    val deviceId: String,
    val clientId: String,
    val clientName: String,
    val token: String,
    val spkiPin: String,
    val host: String,
    val port: Int,
    val pairingId: String,
    val active: Boolean,
    val lastSeenAtMs: Long? = null,
    val named: Boolean = false,
)

internal data class CompanionTargetView(
    val deviceId: String,
    val clientName: String,
    val host: String,
    val port: Int,
    val active: Boolean,
    val lastSeenAtMs: Long?,
)
