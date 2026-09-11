package com.reclash.service.modules

internal data class NetworkFacts(
    val transport: String = "",
    val ssid: String = "",
    val carrier: String = "",
    val gateways: List<String> = emptyList(),
    val dhcp: String = "",
    val dns: List<String> = emptyList(),
    val ipv4: List<String> = emptyList(),
    val validated: Boolean = false,
    val portal: Boolean = false,
    val metered: Boolean = false,
) {
    // Field names are the compatibility wire contract with the Go core.
    fun toJson(): String = buildString {
        append('{')
        appendString("transport", transport)
        append(',')
        appendString("ssid", ssid)
        append(',')
        appendString("carrier", carrier)
        append(',')
        appendStrings("gateways", gateways)
        append(',')
        appendString("dhcp", dhcp)
        append(',')
        appendStrings("dns", dns)
        append(',')
        appendStrings("ipv4", ipv4)
        append(",\"validated\":").append(validated)
        append(",\"portal\":").append(portal)
        append(",\"metered\":").append(metered)
        append('}')
    }
}

private fun StringBuilder.appendString(key: String, value: String) {
    append('"').append(key).append("\":\"").append(rcxEscapeJson(value)).append('"')
}

private fun StringBuilder.appendStrings(key: String, values: List<String>) {
    append('"').append(key).append("\":[")
    values.forEachIndexed { index, value ->
        if (index > 0) append(',')
        append('"').append(rcxEscapeJson(value)).append('"')
    }
    append(']')
}

// An SSID is user-controlled text that reaches the core as JSON.
internal fun rcxEscapeJson(value: String): String = buildString(value.length) {
    value.forEach { char ->
        when {
            char == '"' -> append("\\\"")
            char == '\\' -> append("\\\\")
            char == '\n' -> append("\\n")
            char == '\r' -> append("\\r")
            char == '\t' -> append("\\t")
            char < ' ' -> append("\\u%04x".format(char.code))
            else -> append(char)
        }
    }
}

internal typealias RcxNetworkFacts = NetworkFacts
