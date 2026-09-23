package com.reclash.companion

import java.net.URLDecoder
import java.nio.charset.StandardCharsets

// Kotlin mirror of lib/common/companion_protocol.dart, verified against the same
// test/fixtures/companion/qr_cases.json. base64url is decoded by hand so this stays pure JVM: the
// on-device android.util.Base64 is a stub under unit tests, and the parser must reject before any
// TLS reaches the wire (S01), never turning a subscription URL into a pairing payload (S02).

enum class CompanionQrRejection {
    tooLarge,
    wrongScheme,
    wrongPath,
    hasUserInfo,
    hasFragment,
    unsupportedVersion,
    duplicateParam,
    missingParam,
    invalidDeviceId,
    invalidHost,
    invalidPort,
    invalidPin,
    invalidSecret,
}

data class CompanionPairingPayload(
    val deviceId: String,
    val host: String,
    val port: Int,
    val spkiPin: String,
    val pairingSecret: String,
) {
    val baseUrl: String get() = "https://$host:$port"

    override fun toString(): String =
        "CompanionPairingPayload(deviceId=$deviceId, host=$host, port=$port, " +
            "spkiPin=<redacted>, pairingSecret=<redacted>)"
}

sealed class CompanionQrResult
data class CompanionQrPaired(val payload: CompanionPairingPayload) : CompanionQrResult()
data class CompanionQrRejected(val reason: CompanionQrRejection) : CompanionQrResult()

private const val MAX_QR_BYTES = 2048
private val REQUIRED_PARAMS = setOf("v", "d", "h", "p", "k", "s")

fun parseCompanionPairingQr(raw: String): CompanionQrResult {
    if (raw.toByteArray(StandardCharsets.UTF_8).size > MAX_QR_BYTES) {
        return CompanionQrRejected(CompanionQrRejection.tooLarge)
    }
    val uri = try {
        java.net.URI(raw.trim())
    } catch (_: Exception) {
        return CompanionQrRejected(CompanionQrRejection.wrongScheme)
    }
    if (uri.scheme != "reclash") {
        return CompanionQrRejected(CompanionQrRejection.wrongScheme)
    }
    if (!uri.userInfo.isNullOrEmpty()) {
        return CompanionQrRejected(CompanionQrRejection.hasUserInfo)
    }
    if (!uri.rawFragment.isNullOrEmpty()) {
        return CompanionQrRejected(CompanionQrRejection.hasFragment)
    }
    if (uri.host != "companion" || uri.path != "/pair") {
        return CompanionQrRejected(CompanionQrRejection.wrongPath)
    }

    val params = mutableMapOf<String, String>()
    for ((key, values) in queryParametersAll(uri.rawQuery)) {
        if (values.size != 1) {
            return CompanionQrRejected(CompanionQrRejection.duplicateParam)
        }
        params[key] = values.single()
    }
    for (key in REQUIRED_PARAMS) {
        if (!params.containsKey(key)) {
            return CompanionQrRejected(CompanionQrRejection.missingParam)
        }
    }

    if (params["v"] != "1") {
        return CompanionQrRejected(CompanionQrRejection.unsupportedVersion)
    }
    if (decodeFixed(params.getValue("d"), 16) == null) {
        return CompanionQrRejected(CompanionQrRejection.invalidDeviceId)
    }
    val host = params.getValue("h")
    if (!isPrivateIpv4(host)) {
        return CompanionQrRejected(CompanionQrRejection.invalidHost)
    }
    val portText = params.getValue("p")
    val port = portText.toIntOrNull()
    if (port == null || port < 1 || port > 65535 || port.toString() != portText) {
        return CompanionQrRejected(CompanionQrRejection.invalidPort)
    }
    if (decodeFixed(params.getValue("k"), 32) == null) {
        return CompanionQrRejected(CompanionQrRejection.invalidPin)
    }
    if (decodeFixed(params.getValue("s"), 32) == null) {
        return CompanionQrRejected(CompanionQrRejection.invalidSecret)
    }

    return CompanionQrPaired(
        CompanionPairingPayload(
            deviceId = params.getValue("d"),
            host = host,
            port = port,
            spkiPin = params.getValue("k"),
            pairingSecret = params.getValue("s"),
        ),
    )
}

fun isCompanionPairingLink(raw: String): Boolean = parseCompanionPairingQr(raw) is CompanionQrPaired

private fun queryParametersAll(rawQuery: String?): Map<String, List<String>> {
    val result = linkedMapOf<String, MutableList<String>>()
    if (rawQuery.isNullOrEmpty()) return result
    for (pair in rawQuery.split('&')) {
        if (pair.isEmpty()) continue
        val eq = pair.indexOf('=')
        val rawKey = if (eq < 0) pair else pair.substring(0, eq)
        val rawValue = if (eq < 0) "" else pair.substring(eq + 1)
        val key = URLDecoder.decode(rawKey, StandardCharsets.UTF_8.name())
        val value = URLDecoder.decode(rawValue, StandardCharsets.UTF_8.name())
        result.getOrPut(key) { mutableListOf() }.add(value)
    }
    return result
}

private const val BASE64URL = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

private fun decodeFixed(value: String, expectedLength: Int): ByteArray? {
    val bytes = decodeBase64Url(value) ?: return null
    if (bytes.size != expectedLength) return null
    if (encodeBase64Url(bytes) != value) return null
    return bytes
}

private fun decodeBase64Url(value: String): ByteArray? {
    if (value.any { it == '=' }) return null
    val out = ArrayList<Byte>(value.length * 3 / 4 + 1)
    var buffer = 0
    var bits = 0
    for (ch in value) {
        val index = BASE64URL.indexOf(ch)
        if (index < 0) return null
        buffer = (buffer shl 6) or index
        bits += 6
        if (bits >= 8) {
            bits -= 8
            out.add(((buffer shr bits) and 0xFF).toByte())
        }
    }
    if (bits >= 6) return null
    if ((buffer and ((1 shl bits) - 1)) != 0) return null
    return out.toByteArray()
}

private fun encodeBase64Url(bytes: ByteArray): String {
    val sb = StringBuilder((bytes.size * 4 + 2) / 3)
    var buffer = 0
    var bits = 0
    for (b in bytes) {
        buffer = (buffer shl 8) or (b.toInt() and 0xFF)
        bits += 8
        while (bits >= 6) {
            bits -= 6
            sb.append(BASE64URL[(buffer shr bits) and 0x3F])
        }
    }
    if (bits > 0) {
        sb.append(BASE64URL[(buffer shl (6 - bits)) and 0x3F])
    }
    return sb.toString()
}

private fun isPrivateIpv4(host: String): Boolean {
    val parts = host.split('.')
    if (parts.size != 4) return false
    val octets = IntArray(4)
    for ((i, part) in parts.withIndex()) {
        if (part.isEmpty() || part.length > 3) return false
        if (part.length > 1 && part[0] == '0') return false
        val octet = part.toIntOrNull() ?: return false
        if (octet < 0 || octet > 255) return false
        octets[i] = octet
    }
    val a = octets[0]
    val b = octets[1]
    return a == 10 ||
        (a == 172 && b in 16..31) ||
        (a == 192 && b == 168) ||
        (a == 169 && b == 254)
}
