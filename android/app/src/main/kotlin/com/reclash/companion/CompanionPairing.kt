package com.reclash.companion

import java.security.MessageDigest
import java.security.SecureRandom

// Finite-state handshake for §10.2. Pure and storage-injected so S05 (late approval after
// expiry/cancel saves nothing), S06 (approval write failure never answers approved) and S07 (a
// held token still reads status) are provable on the JVM without a device. The pending token hash
// lives only in memory: a window that closes — cancel, expiry, or Activity backgrounding — burns
// the secret, and no stray approve callback can resurrect it.

internal const val PAIRING_WINDOW_MS = 120_000L
internal const val MAX_WRONG_ATTEMPTS = 5
internal const val ATTEMPT_WINDOW_MS = 60_000L

internal val COMPANION_DEFAULT_SCOPES = listOf(
    "state.read",
    "connection.setRunning",
    "profiles.read",
    "profiles.importUrl",
    "profiles.activate",
    "groups.select",
)

internal data class CompanionTrustedClient(
    val clientId: String,
    val clientName: String,
    val tokenHash: ByteArray,
    val scopes: List<String>,
    val createdAtMs: Long,
    val lastSeenAtMs: Long,
) {
    override fun equals(other: Any?): Boolean =
        other is CompanionTrustedClient &&
            other.clientId == clientId &&
            other.clientName == clientName &&
            other.tokenHash.contentEquals(tokenHash) &&
            other.scopes == scopes

    override fun hashCode(): Int = clientId.hashCode()
}

internal interface CompanionTrustStore {
    fun list(): List<CompanionTrustedClient>
    fun find(clientId: String): CompanionTrustedClient?
    fun matchToken(token: String): CompanionTrustedClient?
    fun put(client: CompanionTrustedClient): Boolean
    fun remove(clientId: String): Boolean
    fun clear()
    fun count(): Int
}

internal sealed class PairingSubmitResult {
    data class Accepted(
        val pairingId: String,
        val confirmationCode: String,
        val expiresInMs: Long,
    ) : PairingSubmitResult()

    data class Rejected(val code: String) : PairingSubmitResult()
}

internal sealed class PairingStatusResult {
    data class Status(val phase: String, val confirmationCode: String?) : PairingStatusResult()
    data class Rejected(val code: String) : PairingStatusResult()
}

internal class CompanionPairing(
    private val trustStore: CompanionTrustStore,
    private val clock: () -> Long,
    private val random: SecureRandom = SecureRandom(),
    private val maxTrustedClients: Int = 8,
) {
    private var window: Window? = null
    private var pending: Pending? = null
    private val wrongAttempts = ArrayDeque<Long>()

    @Synchronized
    fun openWindow(): CompanionPairingWindow {
        val secret = randomToken()
        val now = clock()
        window = Window(secret = secret, openedAtMs = now)
        pending = null
        return CompanionPairingWindow(secret = secret, expiresInMs = PAIRING_WINDOW_MS)
    }

    @Synchronized
    fun cancelWindow() {
        window = null
        pending = null
    }

    @Synchronized
    fun hasOpenWindow(): Boolean = activeWindow() != null || activePending() != null

    @Synchronized
    fun submitPairing(
        secret: String,
        clientId: String,
        clientName: String,
        clientToken: String,
    ): PairingSubmitResult {
        val existing = pending
        if (existing != null && activePending() != null) {
            if (existing.clientId == clientId &&
                MessageDigest.isEqual(existing.tokenHash, sha256(clientToken))
            ) {
                return PairingSubmitResult.Accepted(
                    pairingId = existing.pairingId,
                    confirmationCode = existing.confirmationCode,
                    expiresInMs = remaining(existing.openedAtMs),
                )
            }
            return PairingSubmitResult.Rejected("busy")
        }

        val open = activeWindow()
            ?: return PairingSubmitResult.Rejected("pairingExpired")
        if (isRateLimited()) {
            return PairingSubmitResult.Rejected("busy")
        }
        if (!MessageDigest.isEqual(sha256(secret), sha256(open.secret))) {
            recordWrongAttempt()
            return PairingSubmitResult.Rejected("pairingRejected")
        }
        if (trustStore.count() >= maxTrustedClients && trustStore.find(clientId) == null) {
            return PairingSubmitResult.Rejected("deviceLimit")
        }

        val now = clock()
        val record = Pending(
            pairingId = randomId(),
            clientId = clientId,
            clientName = clientName,
            tokenHash = sha256(clientToken),
            confirmationCode = confirmationCode(),
            openedAtMs = now,
        )
        pending = record
        window = null
        return PairingSubmitResult.Accepted(
            pairingId = record.pairingId,
            confirmationCode = record.confirmationCode,
            expiresInMs = PAIRING_WINDOW_MS,
        )
    }

    @Synchronized
    fun pollStatus(pairingId: String, token: String): PairingStatusResult {
        val record = pending
        if (record == null || record.pairingId != pairingId) {
            val trusted = trustStore.matchToken(token)
            if (trusted != null) {
                return PairingStatusResult.Status("approved", null)
            }
            return PairingStatusResult.Rejected("pairingExpired")
        }
        if (!MessageDigest.isEqual(record.tokenHash, sha256(token))) {
            return PairingStatusResult.Rejected("unauthorized")
        }
        if (activePending() == null) {
            pending = null
            return PairingStatusResult.Rejected("pairingExpired")
        }
        return PairingStatusResult.Status("pending", record.confirmationCode)
    }

    // Local TV confirmation. Returns true only after the trust store durably accepted the client:
    // a storage failure leaves the phone in pending, never approved (S06).
    @Synchronized
    fun approvePending(): Boolean {
        val record = activePending() ?: return false
        val now = clock()
        val stored = trustStore.put(
            CompanionTrustedClient(
                clientId = record.clientId,
                clientName = record.clientName,
                tokenHash = record.tokenHash,
                scopes = COMPANION_DEFAULT_SCOPES,
                createdAtMs = now,
                lastSeenAtMs = now,
            ),
        )
        if (!stored) return false
        pending = null
        window = null
        return true
    }

    @Synchronized
    fun pendingSummary(): CompanionPendingSummary? {
        val record = activePending() ?: return null
        return CompanionPendingSummary(
            clientId = record.clientId,
            clientName = record.clientName,
            confirmationCode = record.confirmationCode,
        )
    }

    private fun activeWindow(): Window? {
        val open = window ?: return null
        if (clock() - open.openedAtMs > PAIRING_WINDOW_MS) {
            window = null
            return null
        }
        return open
    }

    private fun activePending(): Pending? {
        val record = pending ?: return null
        if (clock() - record.openedAtMs > PAIRING_WINDOW_MS) {
            pending = null
            return null
        }
        return record
    }

    private fun remaining(openedAtMs: Long): Long =
        (PAIRING_WINDOW_MS - (clock() - openedAtMs)).coerceAtLeast(0)

    private fun isRateLimited(): Boolean {
        pruneAttempts()
        return wrongAttempts.size >= MAX_WRONG_ATTEMPTS
    }

    private fun recordWrongAttempt() {
        pruneAttempts()
        wrongAttempts.addLast(clock())
    }

    private fun pruneAttempts() {
        val cutoff = clock() - ATTEMPT_WINDOW_MS
        while (wrongAttempts.isNotEmpty() && wrongAttempts.first() < cutoff) {
            wrongAttempts.removeFirst()
        }
    }

    private fun sha256(value: String): ByteArray =
        MessageDigest.getInstance("SHA-256").digest(value.toByteArray(Charsets.UTF_8))

    private fun randomToken(): String = base64Url(ByteArray(32).also(random::nextBytes))

    private fun randomId(): String = base64Url(ByteArray(16).also(random::nextBytes))

    private fun confirmationCode(): String {
        val value = ((random.nextInt() % 1_000_000) + 1_000_000) % 1_000_000
        return value.toString().padStart(6, '0')
    }

    private fun base64Url(bytes: ByteArray): String =
        java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(bytes)

    private data class Window(val secret: String, val openedAtMs: Long)

    private data class Pending(
        val pairingId: String,
        val clientId: String,
        val clientName: String,
        val tokenHash: ByteArray,
        val confirmationCode: String,
        val openedAtMs: Long,
    )
}

internal data class CompanionPairingWindow(val secret: String, val expiresInMs: Long)

internal data class CompanionPendingSummary(
    val clientId: String,
    val clientName: String,
    val confirmationCode: String,
)
