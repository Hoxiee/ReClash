package com.reclash.companion

// Idempotency ledger for §12, keyed by (clientId, serverEpoch, requestId): a retry replays the
// stored receipt, the same requestId with a different payload is a conflict. Bounded, oldest first.
internal class CompanionCommandRegistry(private val maxPerEpoch: Int = MAX_RECEIPTS) {
    private val receipts = LinkedHashMap<String, Receipt>()
    private val lock = Any()

    fun resolve(
        clientId: String,
        serverEpoch: String,
        requestId: String,
        payloadHash: Int,
        run: () -> Map<String, Any?>,
    ): CommandOutcome = synchronized(lock) {
        val key = "$clientId|$serverEpoch|$requestId"
        val existing = receipts[key]
        if (existing != null) {
            return if (existing.payloadHash == payloadHash) {
                CommandOutcome.Replay(existing.result)
            } else {
                CommandOutcome.Conflict
            }
        }
        val result = run()
        if (receipts.size >= maxPerEpoch) {
            val oldest = receipts.keys.firstOrNull()
            if (oldest != null) receipts.remove(oldest)
        }
        receipts[key] = Receipt(payloadHash, result)
        CommandOutcome.Fresh(result)
    }

    fun clear() = synchronized(lock) { receipts.clear() }

    private data class Receipt(val payloadHash: Int, val result: Map<String, Any?>)

    companion object {
        private const val MAX_RECEIPTS = 256
    }
}

internal sealed class CommandOutcome {
    data class Fresh(val result: Map<String, Any?>) : CommandOutcome()
    data class Replay(val result: Map<String, Any?>) : CommandOutcome()
    object Conflict : CommandOutcome()
}
