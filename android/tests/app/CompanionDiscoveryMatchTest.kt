package com.reclash.companion

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CompanionDiscoveryMatchTest {
    private val deviceId = "abc123_deviceId"

    @Test
    fun `found-time name carrying the deviceId matches before attributes resolve`() {
        assertTrue(companionServiceMatches("reclash-cpn-$deviceId", null, deviceId))
    }

    @Test
    fun `resolved TXT id is authoritative over the name`() {
        assertTrue(companionServiceMatches("renamed (2)", deviceId, deviceId))
        assertFalse(companionServiceMatches("reclash-cpn-$deviceId", "other", deviceId))
    }

    @Test
    fun `an unrelated service is not matched`() {
        assertFalse(companionServiceMatches("some-printer", null, deviceId))
        assertFalse(companionServiceMatches(null, null, deviceId))
    }
}
