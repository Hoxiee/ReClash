package com.reclash.service.modules

import java.net.Inet6Address
import java.net.InetAddress

object SmartPausePolicy {

    // A start on a trusted network should visibly complete before the pause lands.
    const val STARTUP_GUARD_MS = 8_000L

    const val TRANSITION_RETRIES = 3
    const val TRANSITION_BACKOFF_MS = 1_000L

    const val DECISION_DEBOUNCE_MS = 2_000L
}

enum class SmartPauseDecision { NONE, PAUSE, DEFER, RESUME }

data class SmartPauseConfig(
    val enabled: Boolean = false,
    val networks: List<String> = emptyList(),
    val strict: Boolean = false,
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
    ssidHit: Boolean = trusted,
    subnetHit: Boolean = trusted,
): SmartPauseDecision {
    if (!config.enabled || config.networks.isEmpty()) {
        return if (session.paused) SmartPauseDecision.RESUME else SmartPauseDecision.NONE
    }
    // A half-up link reports no addresses at all; acting on empty data is how a false resume happens.
    if (!networkKnown) return SmartPauseDecision.NONE
    val effectiveTrusted =
        if (config.strict && TrustedNetworkMatcher.hasBothRuleKinds(config.networks)) {
            ssidHit && subnetHit
        } else {
            trusted
        }
    if (session.paused) {
        return if (effectiveTrusted) SmartPauseDecision.NONE else SmartPauseDecision.RESUME
    }
    if (!session.running || !effectiveTrusted) return SmartPauseDecision.NONE
    return if (session.sessionAgeMs >= SmartPausePolicy.STARTUP_GUARD_MS) {
        SmartPauseDecision.PAUSE
    } else {
        SmartPauseDecision.DEFER
    }
}

// The retry plan schedules a fresh evaluation event instead of replaying the
// old action: an inline backoff would head-of-line block the conflated consumer.
fun transitionRetryPlan(attempts: Int): Long? =
    if (attempts >= SmartPausePolicy.TRANSITION_RETRIES) null
    else SmartPausePolicy.TRANSITION_BACKOFF_MS shl attempts

// Hand-mirrored by Dart's smartPauseMatches in lib/common/network.dart.
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

    fun matchesAny(addresses: List<String>, networks: List<String>): Boolean =
        matchedIpRules(addresses, networks).isNotEmpty()

    fun matchedIpRules(addresses: List<String>, networks: List<String>): List<String> {
        if (addresses.isEmpty() || networks.isEmpty()) return emptyList()
        return networks.filter { rule ->
            val v4 = parseCidr(rule)
            if (v4 != null) {
                val (network, prefix) = v4
                addresses.any { addr ->
                    parseIpv4(addr)?.let { matches(it, network, prefix) } == true
                }
            } else {
                val parsed = parseIpNetwork(rule) ?: return@filter false
                addresses.any { addr ->
                    parseIpBytes(addr)?.let { matchesNetwork(it, parsed) } == true
                }
            }
        }
    }

    // Exact, case-insensitive name match — a blank entry would trust every blank live name.
    fun matchesSsid(liveSsids: List<String>, trustedSsids: List<String>): Boolean =
        matchSsid(liveSsids, trustedSsids) != null

    fun matchSsid(liveSsids: List<String>, trustedSsids: List<String>): String? {
        if (liveSsids.isEmpty() || trustedSsids.isEmpty()) return null
        val trusted = trustedSsids.mapNotNull { it.trim().lowercase().ifBlank { null } }
        if (trusted.isEmpty()) return null
        return liveSsids.firstNotNullOfOrNull { live ->
            val low = live.trim().lowercase()
            trusted.firstOrNull { it == low }
        }
    }

    fun isSubnetRule(text: String): Boolean =
        parseCidr(text) != null || parseIpNetwork(text) != null

    fun hasBothRuleKinds(networks: List<String>): Boolean =
        networks.any { !isSubnetRule(it) } && networks.any { isSubnetRule(it) }

    data class ParsedNetwork(val bytes: ByteArray, val prefix: Int)

    fun parseIpNetwork(text: String): ParsedNetwork? {
        val trimmed = text.trim()
        val idx = trimmed.indexOf('/')
        val addrPart = if (idx == -1) trimmed else trimmed.substring(0, idx)
        val prefixPart = if (idx == -1) null else trimmed.substring(idx + 1)
        if (!addrPart.contains(':')) return null
        var host = addrPart.trim().removePrefix("[").removeSuffix("]")
        val zone = host.indexOf('%')
        if (zone != -1) host = host.substring(0, zone)
        if (host.any { it !in "0123456789abcdefABCDEF:." }) return null
        val raw = runCatching { InetAddress.getByName(host) }.getOrNull()
        if (raw !is Inet6Address) return null
        val prefix = if (prefixPart == null) 128 else prefixPart.toIntOrNull() ?: return null
        if (prefix !in 0..128) return null
        val masked = raw.address.copyOf()
        for (i in prefix until 128) {
            masked[i / 8] = (masked[i / 8].toInt() and (1 shl (7 - i % 8)).inv()).toByte()
        }
        return ParsedNetwork(masked, prefix)
    }

    fun parseIpBytes(text: String): ByteArray? {
        val trimmed = text.trim()
        if (trimmed.contains(':')) {
            var host = trimmed.removePrefix("[").removeSuffix("]")
            val zone = host.indexOf('%')
            if (zone != -1) host = host.substring(0, zone)
            val raw = runCatching { InetAddress.getByName(host) }.getOrNull()
            return (raw as? Inet6Address)?.address
        }
        val v4 = parseIpv4(trimmed) ?: return null
        return byteArrayOf(
            (v4 ushr 24).toByte(),
            (v4 ushr 16).toByte(),
            (v4 ushr 8).toByte(),
            v4.toByte(),
        )
    }

    fun matchesNetwork(address: ByteArray, network: ParsedNetwork): Boolean {
        if (address.size != network.bytes.size || network.prefix <= 0) return false
        val full = network.prefix / 8
        for (i in 0 until full) {
            if (address[i] != network.bytes[i]) return false
        }
        val rest = network.prefix % 8
        if (rest != 0) {
            val mask = (0xFF shl (8 - rest)) and 0xFF
            if ((address[full].toInt() and mask) != (network.bytes[full].toInt() and mask)) {
                return false
            }
        }
        return true
    }
}
