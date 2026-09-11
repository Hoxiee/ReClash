package com.reclash.service.modules

import java.security.MessageDigest

// Link facts like the Go core's fingerprint, salted with the SSID: same-model routers
// in different venues must not share a strategy cache, and a rename only costs a re-probe.
internal fun byeDpiEnvKey(facts: NetworkFacts): String {
    val parts = buildList {
        addAll(facts.gateways)
        add(facts.dhcp)
        addAll(facts.dns)
        add(facts.ssid)
    }.filter(String::isNotEmpty).sorted()
    if (parts.isEmpty()) return ""
    val digest = MessageDigest.getInstance("SHA-256").digest(parts.joinToString("|").toByteArray())
    return digest.take(8).joinToString("") { byte -> "%02x".format(byte) }
}
