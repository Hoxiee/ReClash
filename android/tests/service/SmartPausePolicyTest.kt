package com.reclash.service.modules

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class SmartPausePolicyTest {

    private val config = SmartPauseConfig(enabled = true, networks = listOf("192.168.1.0/24"))
    private fun session(
        running: Boolean = true,
        paused: Boolean = false,
        ageMs: Long = 60_000,
    ) = SmartPauseSessionState(running, paused, ageMs)

    @Test
    fun `disabled smart pause never decides`() {
        val decision = evaluateSmartPause(
            SmartPauseConfig(enabled = false, networks = listOf("10.0.0.0/8")),
            session(),
            networkKnown = true,
            trusted = true,
        )
        assertEquals(SmartPauseDecision.NONE, decision)
    }

    @Test
    fun `empty trusted list never decides`() {
        val decision = evaluateSmartPause(
            SmartPauseConfig(enabled = true, networks = emptyList()),
            session(),
            networkKnown = true,
            trusted = true,
        )
        assertEquals(SmartPauseDecision.NONE, decision)
    }

    @Test
    fun `disabling the policy releases an active policy pause`() {
        assertEquals(
            SmartPauseDecision.RESUME,
            evaluateSmartPause(
                SmartPauseConfig(enabled = false, networks = listOf("10.0.0.0/8")),
                session(paused = true),
                networkKnown = false,
                trusted = true,
            ),
        )
    }

    @Test
    fun `emptying the trusted list releases an active policy pause`() {
        assertEquals(
            SmartPauseDecision.RESUME,
            evaluateSmartPause(
                SmartPauseConfig(enabled = true, networks = emptyList()),
                session(paused = true),
                networkKnown = false,
                trusted = true,
            ),
        )
    }

    @Test
    fun `unknown network never decides`() {
        val decision = evaluateSmartPause(config, session(), networkKnown = false, trusted = false)
        assertEquals(SmartPauseDecision.NONE, decision)
    }

    @Test
    fun `trusted network pauses a running session past the guard`() {
        assertEquals(
            SmartPauseDecision.PAUSE,
            evaluateSmartPause(config, session(), true, trusted = true),
        )
    }

    @Test
    fun `trusted network defers the pause for a young session`() {
        assertEquals(
            SmartPauseDecision.DEFER,
            evaluateSmartPause(
                config,
                session(ageMs = SmartPausePolicy.STARTUP_GUARD_MS - 1),
                true,
                trusted = true,
            ),
        )
    }

    @Test
    fun `trusted network pauses exactly at the guard`() {
        assertEquals(
            SmartPauseDecision.PAUSE,
            evaluateSmartPause(
                config,
                session(ageMs = SmartPausePolicy.STARTUP_GUARD_MS),
                true,
                trusted = true,
            ),
        )
    }

    @Test
    fun `untrusted young session does not defer`() {
        assertEquals(
            SmartPauseDecision.NONE,
            evaluateSmartPause(
                config,
                session(ageMs = SmartPausePolicy.STARTUP_GUARD_MS - 1),
                true,
                trusted = false,
            ),
        )
    }

    @Test
    fun `untrusted network does not pause`() {
        assertEquals(
            SmartPauseDecision.NONE,
            evaluateSmartPause(config, session(), true, trusted = false),
        )
    }

    @Test
    fun `paused session resumes only off the trusted network`() {
        assertEquals(
            SmartPauseDecision.NONE,
            evaluateSmartPause(config, session(paused = true), true, trusted = true),
        )
        assertEquals(
            SmartPauseDecision.RESUME,
            evaluateSmartPause(config, session(paused = true), true, trusted = false),
        )
    }

    @Test
    fun `paused session with unknown network stays paused`() {
        assertEquals(
            SmartPauseDecision.NONE,
            evaluateSmartPause(config, session(paused = true), networkKnown = false, trusted = false),
        )
    }

    @Test
    fun `retry plan backs off exponentially then gives up`() {
        assertEquals(1_000L, transitionRetryPlan(0))
        assertEquals(2_000L, transitionRetryPlan(1))
        assertEquals(4_000L, transitionRetryPlan(2))
        assertNull(transitionRetryPlan(3))
        assertNull(transitionRetryPlan(4))
    }

    @Test
    fun `ipv4 parser rejects malformed addresses`() {
        assertEquals(0, TrustedNetworkMatcher.parseIpv4("0.0.0.0"))
        assertEquals(0x0A000001, TrustedNetworkMatcher.parseIpv4("10.0.0.1"))
        assertNull(TrustedNetworkMatcher.parseIpv4("10.0.0"))
        assertNull(TrustedNetworkMatcher.parseIpv4("10.0.0.256"))
        assertNull(TrustedNetworkMatcher.parseIpv4("10.0.0.01"))
        assertNull(TrustedNetworkMatcher.parseIpv4("10.0.0.-1"))
        assertNull(TrustedNetworkMatcher.parseIpv4("10.0.0.1.2"))
        assertNull(TrustedNetworkMatcher.parseIpv4(""))
        assertNull(TrustedNetworkMatcher.parseIpv4("abc.def.ghi.jkl"))
    }

    @Test
    fun `bare ipv4 parses as a single host network`() {
        assertEquals(
            Pair(0x0A000001, 32),
            TrustedNetworkMatcher.parseCidr("10.0.0.1"),
        )
        assertEquals(Pair(0, 0), TrustedNetworkMatcher.parseCidr("0.0.0.0/0"))
        assertNull(TrustedNetworkMatcher.parseCidr("10.0.0.0/33"))
        assertNull(TrustedNetworkMatcher.parseCidr("10.0.0.0/x"))
    }

    @Test
    fun `cidr match follows the prefix`() {
        assertTrue(TrustedNetworkMatcher.matches(0x0A000001, 0x0A000000, 8))
        assertTrue(TrustedNetworkMatcher.matches(0x0A000001, 0x0A000001, 32))
        assertFalse(TrustedNetworkMatcher.matches(0x0A000002, 0x0A000001, 32))
        assertFalse(TrustedNetworkMatcher.matches(0x0B000001, 0x0A000000, 8))
        assertFalse(TrustedNetworkMatcher.matches(0x0A000001, 0, 0))
    }

    @Test
    fun `matchesAny handles subnets and bare hosts`() {
        val networks = listOf("192.168.1.0/24", "10.0.0.7")
        assertTrue(TrustedNetworkMatcher.matchesAny(listOf("192.168.1.55"), networks))
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("192.168.2.55"), networks))
        assertTrue(TrustedNetworkMatcher.matchesAny(listOf("10.0.0.7"), networks))
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("10.0.0.8"), networks))
        assertFalse(TrustedNetworkMatcher.matchesAny(emptyList(), networks))
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("192.168.1.55"), emptyList()))
    }

    @Test
    fun `ssid match is exact and case-insensitive`() {
        assertTrue(TrustedNetworkMatcher.matchesSsid(listOf("Home Wi-Fi"), listOf("home wi-fi")))
        assertFalse(TrustedNetworkMatcher.matchesSsid(listOf("Home Wi-Fi Extra"), listOf("home wi-fi")))
        assertFalse(TrustedNetworkMatcher.matchesSsid(listOf("Home Wi-Fi"), listOf("  ")))
        assertFalse(TrustedNetworkMatcher.matchesSsid(emptyList(), listOf("home wi-fi")))
    }

    @Test
    fun `ipv6 subnet rules match local ipv6 addresses`() {
        val networks = listOf("fd00:db8:1::/48", "fe80::1")
        assertTrue(TrustedNetworkMatcher.matchesAny(listOf("fd00:db8:1::42"), networks))
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("fd00:db8:2::42"), networks))
        assertTrue(TrustedNetworkMatcher.matchesAny(listOf("fe80::1"), networks))
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("fe80::2"), networks))
        assertTrue(TrustedNetworkMatcher.matchesAny(listOf("2001:db8::1"), listOf("2001:db8::/32")))
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("2001:db8:8000::1"), listOf("2001:db8::/33")))
    }

    @Test
    fun `ipv6 and ipv4 families never cross-match`() {
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("fd00::1"), listOf("192.168.1.0/24")))
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("192.168.1.5"), listOf("fd00::/8")))
        assertFalse(TrustedNetworkMatcher.matchesAny(listOf("fd00::1"), listOf("::/0")))
    }

    @Test
    fun `strict config needs both an ssid and a subnet hit`() {
        val strict = SmartPauseConfig(
            enabled = true,
            networks = listOf("Home Wi-Fi", "192.168.1.0/24"),
            strict = true,
        )
        assertEquals(
            SmartPauseDecision.PAUSE,
            evaluateSmartPause(strict, session(), true, trusted = true, ssidHit = true, subnetHit = true),
        )
        assertEquals(
            SmartPauseDecision.NONE,
            evaluateSmartPause(strict, session(), true, trusted = true, ssidHit = true, subnetHit = false),
        )
        assertEquals(
            SmartPauseDecision.NONE,
            evaluateSmartPause(strict, session(), true, trusted = true, ssidHit = false, subnetHit = true),
        )
    }

    @Test
    fun `strict falls back without both rule kinds`() {
        val strictSsids = SmartPauseConfig(enabled = true, networks = listOf("Home Wi-Fi"), strict = true)
        assertEquals(
            SmartPauseDecision.PAUSE,
            evaluateSmartPause(strictSsids, session(), true, trusted = true),
        )
        assertEquals(
            SmartPauseDecision.RESUME,
            evaluateSmartPause(strictSsids, session(paused = true), true, trusted = false),
        )
    }

    @Test
    fun `non-strict config keeps the combined trust signal`() {
        val loose = SmartPauseConfig(
            enabled = true,
            networks = listOf("Home Wi-Fi", "192.168.1.0/24"),
        )
        assertEquals(
            SmartPauseDecision.PAUSE,
            evaluateSmartPause(loose, session(), true, trusted = true, ssidHit = true, subnetHit = false),
        )
    }
}
