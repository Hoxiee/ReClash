package com.reclash.companion

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

// Shares test/fixtures/companion/qr_cases.json with the Dart parser test so the two
// implementations cannot drift: a QR the phone accepts is one the TV accepts, byte for byte.
class CompanionProtocolTest {
    private val gson = Gson()
    private val fixtures: Map<String, Any> = loadFixtures()

    @Test
    fun `valid QR parses to the expected typed payload`() {
        @Suppress("UNCHECKED_CAST")
        val valid = fixtures["valid"] as Map<String, Any>
        val result = parseCompanionPairingQr(valid["raw"] as String)

        assertTrue(result is CompanionQrPaired)
        val payload = (result as CompanionQrPaired).payload
        assertEquals(valid["deviceId"], payload.deviceId)
        assertEquals(valid["host"], payload.host)
        assertEquals((valid["port"] as Double).toInt(), payload.port)
        assertEquals(valid["spkiPin"], payload.spkiPin)
        assertEquals(valid["pairingSecret"], payload.pairingSecret)
        assertEquals("https://${valid["host"]}:${payload.port}", payload.baseUrl)
    }

    @Test
    fun `every malformed QR is rejected with its typed reason`() {
        @Suppress("UNCHECKED_CAST")
        val rejected = fixtures["rejected"] as List<Map<String, Any>>
        for (entry in rejected) {
            val result = parseCompanionPairingQr(entry["raw"] as String)
            assertTrue("expected rejection for ${entry["reason"]}", result is CompanionQrRejected)
            assertEquals(
                entry["raw"] as String,
                entry["reason"],
                (result as CompanionQrRejected).reason.name,
            )
        }
    }

    @Test
    fun `oversize input is rejected before any parsing`() {
        val huge = "reclash://companion/pair?v=1&x=" + "a".repeat(3000)
        val result = parseCompanionPairingQr(huge)
        assertEquals(CompanionQrRejected(CompanionQrRejection.tooLarge), result)
    }

    @Test
    fun `parsed payload never leaks the secret or pin in toString`() {
        @Suppress("UNCHECKED_CAST")
        val valid = fixtures["valid"] as Map<String, Any>
        val payload = (parseCompanionPairingQr(valid["raw"] as String) as CompanionQrPaired).payload
        val text = payload.toString()
        assertTrue(text.contains("<redacted>"))
        assertTrue(!text.contains(payload.pairingSecret))
        assertTrue(!text.contains(payload.spkiPin))
    }

    private fun loadFixtures(): Map<String, Any> {
        var dir: File? = File(System.getProperty("user.dir") ?: ".")
        while (dir != null) {
            val candidate = File(dir, "test/fixtures/companion/qr_cases.json")
            if (candidate.exists()) {
                val type = object : TypeToken<Map<String, Any>>() {}.type
                return gson.fromJson(candidate.readText(), type)
            }
            dir = dir.parentFile
        }
        throw IllegalStateException("qr_cases.json fixture not found from ${System.getProperty("user.dir")}")
    }
}
