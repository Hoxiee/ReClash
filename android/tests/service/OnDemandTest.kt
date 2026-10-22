package com.reclash.service.modules

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class OnDemandTest {
    @Test
    fun `startup guard and unknown snapshots prevent premature pause or resume`() {
        val config = OnDemandConfig(true, listOf("Home"))
        assertEquals(OnDemandDecision.DEFER, evaluateOnDemand(config, OnDemandSessionState(true, false, 100), true, true))
        assertEquals(OnDemandDecision.PAUSE, evaluateOnDemand(config, OnDemandSessionState(true, false, 8000), true, true))
        assertEquals(OnDemandDecision.NONE, evaluateOnDemand(config, OnDemandSessionState(true, true, 8000), false, false))
        assertEquals(OnDemandDecision.RESUME, evaluateOnDemand(config.copy(enabled = false), OnDemandSessionState(true, true, 8000), false, false))
    }

    @Test
    fun `SSID rules keep case and whitespace while subnets support both IP families`() {
        assertFalse(TrustedNetworkMatcher.matchesSsid(listOf("home"), listOf("Home")))
        assertFalse(TrustedNetworkMatcher.matchesSsid(listOf(" Home "), listOf("Home")))
        assertTrue(TrustedNetworkMatcher.matchesSsid(listOf(" Home "), listOf(" Home ")))
        assertTrue(TrustedNetworkMatcher.matchesAny(listOf("192.168.1.5", "2001:db8:1234::1"), listOf("192.168.1.0/24", "2001:db8::/32")))
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("192.168.1.5", "2001:db8::1"), listOf("0.0.0.0/0", "::/0")))
    }

    @Test
    fun `strict policy requires SSID and subnet only when both rule kinds exist`() {
        val session = OnDemandSessionState(true, false, 9000)
        val mixed = OnDemandConfig(true, listOf("Home", "192.168.1.0/24"), true)
        assertEquals(OnDemandDecision.NONE, evaluateOnDemand(mixed, session, true, true, true, false))
        assertEquals(OnDemandDecision.PAUSE, evaluateOnDemand(mixed, session, true, true, true, true))
        assertEquals(OnDemandDecision.PAUSE, evaluateOnDemand(mixed.copy(networks = listOf("Home")), session, true, true, true, false))
    }
}
