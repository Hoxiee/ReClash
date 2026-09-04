package com.reclash.service.modules

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ByeDpiArgsTest {

    @Test
    fun `listener and cache ttl are always present`() {
        val args = byeDpiArgs(port = 7898)
        assertEquals(BYEDPI_LOOPBACK, args[args.indexOf("-i") + 1])
        assertEquals("7898", args[args.indexOf("-p") + 1])
        assertEquals(BYEDPI_CACHE_TTL_SECONDS.toString(), args[args.indexOf("-u") + 1])
    }

    @Test
    fun `cache file and protect path are omitted when absent`() {
        val args = byeDpiArgs(port = 7898)
        assertTrue("-y" !in args)
        assertTrue("-P" !in args)
    }

    @Test
    fun `cache file and protect path are passed through`() {
        val args = byeDpiArgs(
            port = 7898,
            cacheFile = "/data/byedpi/abc.cache",
            protectPath = "/data/byedpi.protect",
        )
        assertEquals("/data/byedpi/abc.cache", args[args.indexOf("-y") + 1])
        assertEquals("/data/byedpi.protect", args[args.indexOf("-P") + 1])
    }

    // Nothing may precede the first -A: options there form the group ByeDPI applies
    // unconditionally, which would desync sites that were never blocked.
    @Test
    fun `no strategy sits outside a trigger group`() {
        val args = byeDpiArgs(port = 7898, ladder = listOf(listOf("--split", "1")))
        val head = args.subList(0, args.indexOf("-A"))
        assertEquals(listOf("-i", BYEDPI_LOOPBACK, "-p", "7898", "-u", "100800"), head)
    }

    @Test
    fun `every ladder step opens its own group`() {
        val args = byeDpiArgs(port = 7898)
        assertEquals(BYEDPI_LADDER.size, args.count { it == "-A" })
        assertEquals(BYEDPI_LADDER.size, args.count { it == "-L" })
    }

    @Test
    fun `env key ignores the ssid and follows the link`() {
        val home = RcxNetworkFacts(
            ssid = "Home",
            gateways = listOf("192.168.1.1"),
            dhcp = "192.168.1.1",
            dns = listOf("192.168.1.1"),
        )
        assertEquals(byeDpiEnvKey(home), byeDpiEnvKey(home.copy(ssid = "Home 5GHz")))
        assertNotEquals(byeDpiEnvKey(home), byeDpiEnvKey(home.copy(gateways = listOf("10.0.0.1"))))
    }

    @Test
    fun `env key is empty when the link is unknown`() {
        assertEquals("", byeDpiEnvKey(RcxNetworkFacts()))
    }

    @Test
    fun `backoff grows and is capped`() {
        assertEquals(1_000L, ByeDpiPolicy.backoffMs(0))
        assertEquals(2_000L, ByeDpiPolicy.backoffMs(1))
        assertEquals(ByeDpiPolicy.MAX_BACKOFF_MS, ByeDpiPolicy.backoffMs(9))
    }
}
