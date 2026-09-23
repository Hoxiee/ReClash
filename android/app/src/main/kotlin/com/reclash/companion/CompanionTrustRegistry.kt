package com.reclash.companion

import com.google.gson.Gson
import java.io.File
import java.security.MessageDigest

// Atomic, backup-excluded pairing registry (S14): only the SHA-256 of a high-entropy random token
// is persisted, never the token, a subscription URL or a private key. data_extraction_rules.xml
// keeps this file out of cloud/device backup. Token lookup is constant-time per candidate.
internal class CompanionFileTrustStore(
    private val file: File,
    private val maxTrustedClients: Int = 8,
) : CompanionTrustStore {
    private val gson = Gson()
    private val lock = Any()

    override fun list(): List<CompanionTrustedClient> = synchronized(lock) { read() }

    override fun find(clientId: String): CompanionTrustedClient? =
        synchronized(lock) { read().firstOrNull { it.clientId == clientId } }

    override fun matchToken(token: String): CompanionTrustedClient? {
        val presented = sha256(token)
        return synchronized(lock) {
            var found: CompanionTrustedClient? = null
            for (client in read()) {
                if (MessageDigest.isEqual(presented, client.tokenHash)) {
                    found = client
                }
            }
            found
        }
    }

    override fun put(client: CompanionTrustedClient): Boolean = synchronized(lock) {
        val current = read().filterNot { it.clientId == client.clientId }
        if (current.size >= maxTrustedClients) return false
        write(current + client)
        true
    }

    override fun remove(clientId: String): Boolean = synchronized(lock) {
        val current = read()
        val next = current.filterNot { it.clientId == clientId }
        if (next.size == current.size) return false
        write(next)
        true
    }

    override fun clear() = synchronized(lock) {
        if (file.exists()) file.delete()
        Unit
    }

    override fun count(): Int = synchronized(lock) { read().size }

    private fun read(): List<CompanionTrustedClient> {
        if (!file.exists()) return emptyList()
        return try {
            file.readText().takeIf { it.isNotBlank() }?.let { text ->
                gson.fromJson(text, Array<StoredClient>::class.java).map { it.toDomain() }
            } ?: emptyList()
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun write(clients: List<CompanionTrustedClient>) {
        file.parentFile?.mkdirs()
        val tmp = File(file.parentFile, "${file.name}.tmp")
        tmp.writeText(gson.toJson(clients.map(StoredClient::fromDomain)))
        if (!tmp.renameTo(file)) {
            file.delete()
            tmp.renameTo(file)
        }
    }

    private fun sha256(value: String): ByteArray =
        MessageDigest.getInstance("SHA-256").digest(value.toByteArray(Charsets.UTF_8))

    // base64 (not url) for the stored hash blob; the token itself is never written.
    private data class StoredClient(
        val clientId: String,
        val clientName: String,
        val tokenHashB64: String,
        val scopes: List<String>,
        val createdAtMs: Long,
        val lastSeenAtMs: Long,
    ) {
        fun toDomain() = CompanionTrustedClient(
            clientId = clientId,
            clientName = clientName,
            tokenHash = java.util.Base64.getDecoder().decode(tokenHashB64),
            scopes = scopes,
            createdAtMs = createdAtMs,
            lastSeenAtMs = lastSeenAtMs,
        )

        companion object {
            fun fromDomain(client: CompanionTrustedClient) = StoredClient(
                clientId = client.clientId,
                clientName = client.clientName,
                tokenHashB64 = java.util.Base64.getEncoder().encodeToString(client.tokenHash),
                scopes = client.scopes,
                createdAtMs = client.createdAtMs,
                lastSeenAtMs = client.lastSeenAtMs,
            )
        }
    }
}
