package com.reclash.service.modules

import java.security.MessageDigest

/// Keyed on the same facts the Go core fingerprints a link with — gateway, DHCP server,
/// resolvers — because an SSID is shared by unrelated networks and changes without them.
internal fun byeDpiEnvKey(facts: RcxNetworkFacts): String {
    val parts = buildList {
        addAll(facts.gateways)
        add(facts.dhcp)
        addAll(facts.dns)
    }.filter(String::isNotEmpty).sorted()
    if (parts.isEmpty()) return ""
    val digest = MessageDigest.getInstance("SHA-256").digest(parts.joinToString("|").toByteArray())
    return digest.take(8).joinToString("") { byte -> "%02x".format(byte) }
}
