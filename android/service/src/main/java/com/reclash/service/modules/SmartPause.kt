package com.reclash.service.modules

object SmartPausePolicy {

    // A start on a trusted network should visibly complete before the pause lands.
    const val STARTUP_GUARD_MS = 8_000L

    const val TRANSITION_RETRIES = 3
    const val TRANSITION_BACKOFF_MS = 1_000L

    const val DECISION_DEBOUNCE_MS = 2_000L
}

enum class SmartPauseDecision { NONE, PAUSE, RESUME }

data class SmartPauseConfig(
    val enabled: Boolean = false,
    val networks: List<String> = emptyList(),
)

data class SmartPauseSessionState(
    val running: Boolean,
    val paused: Boolean,
    val sessionAgeMs: Long,
)

fun evaluateSmartPause(
    config: SmartPauseConfig,
    session: SmartPauseSessionState,
    networkKnown: Boolean,
    trusted: Boolean,
): SmartPauseDecision {
    if (!config.enabled || config.networks.isEmpty()) {
        return if (session.paused) SmartPauseDecision.RESUME else SmartPauseDecision.NONE
    }
    // A half-up link reports no addresses at all; acting on empty data is how a false resume happens.
    if (!networkKnown) return SmartPauseDecision.NONE
    if (session.paused) {
        return if (trusted) SmartPauseDecision.NONE else SmartPauseDecision.RESUME
    }
    if (!session.running) return SmartPauseDecision.NONE
    if (trusted && session.sessionAgeMs >= SmartPausePolicy.STARTUP_GUARD_MS) {
        return SmartPauseDecision.PAUSE
    }
    return SmartPauseDecision.NONE
}

// The retry plan schedules a fresh evaluation event instead of replaying the
// old action: an inline backoff would head-of-line block the conflated consumer.
fun transitionRetryPlan(attempts: Int): Long? =
    if (attempts >= SmartPausePolicy.TRANSITION_RETRIES) null
    else SmartPausePolicy.TRANSITION_BACKOFF_MS shl attempts

object TrustedNetworkMatcher {

    fun parseIpv4(text: String): Int? {
        val parts = text.trim().split('.')
        if (parts.size != 4) return null
        var value = 0
        for (part in parts) {
            if (part.isEmpty() || part.length > 3) return null
            if (part.length > 1 && part[0] == '0') return null
            val octet = part.toIntOrNull() ?: return null
            if (octet !in 0..255) return null
            value = (value shl 8) or octet
        }
        return value
    }

    fun parseCidr(text: String): Pair<Int, Int>? {
        val trimmed = text.trim()
        val (addrPart, prefixPart) = if (trimmed.contains('/')) {
            val idx = trimmed.indexOf('/')
            trimmed.substring(0, idx) to trimmed.substring(idx + 1)
        } else {
            trimmed to "32"
        }
        val prefix = prefixPart.toIntOrNull() ?: return null
        if (prefix !in 0..32) return null
        val addr = parseIpv4(addrPart) ?: return null
        val mask = if (prefix == 0) 0 else (-1) shl (32 - prefix)
        return (addr and mask) to prefix
    }

    fun matches(address: Int, network: Int, prefix: Int): Boolean = when {
        prefix <= 0 -> false
        prefix >= 32 -> address == network
        else -> address ushr (32 - prefix) == network ushr (32 - prefix)
    }

    fun matchesAny(addresses: List<String>, networks: List<String>): Boolean {
        if (addresses.isEmpty() || networks.isEmpty()) return false
        val parsedNetworks = networks.mapNotNull { parseCidr(it) }
        if (parsedNetworks.isEmpty()) return false
        return addresses.any { addrText ->
            val addr = parseIpv4(addrText) ?: return@any false
            parsedNetworks.any { (network, prefix) -> matches(addr, network, prefix) }
        }
    }

    // Exact, case-insensitive name match — a blank entry would trust every blank live name.
    fun matchesSsid(liveSsids: List<String>, trustedSsids: List<String>): Boolean {
        if (liveSsids.isEmpty() || trustedSsids.isEmpty()) return false
        val trusted = trustedSsids.mapNotNull { it.trim().lowercase().ifBlank { null } }.toSet()
        if (trusted.isEmpty()) return false
        return liveSsids.any { it.trim().lowercase() in trusted }
    }
}
