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

    @Test
    fun `a disabled cache drops the file even when present`() {
        val args = byeDpiArgs(
            port = 7898,
            cacheFile = "/data/byedpi/abc.cache",
            cacheEnabled = false,
        )
        assertTrue("-y" !in args)
    }

    @Test
    fun `a custom cache ttl replaces the default`() {
        val args = byeDpiArgs(port = 7898, cacheTtlSeconds = 60)
        assertEquals("60", args[args.indexOf("-u") + 1])
    }

    @Test
    fun `the user strategy follows the managed block verbatim`() {
        val strategy = listOf("-A", "torst,conn", "-L", "s,o", "--split", "1")
        val args = byeDpiArgs(port = 7899, strategy = strategy)
        assertEquals(
            listOf("-i", BYEDPI_LOOPBACK, "-p", "7899", "-u", BYEDPI_CACHE_TTL_SECONDS.toString()),
            args.subList(0, 6),
        )
        assertEquals(strategy, args.subList(6, args.size))
    }

    @Test
    fun `env key follows the link and salts it with the ssid`() {
        val home = RcxNetworkFacts(
            ssid = "Home",
            gateways = listOf("192.168.1.1"),
            dhcp = "192.168.1.1",
            dns = listOf("192.168.1.1"),
        )
        assertNotEquals(byeDpiEnvKey(home), byeDpiEnvKey(home.copy(ssid = "Cafe")))
        assertNotEquals(byeDpiEnvKey(home), byeDpiEnvKey(home.copy(ssid = "")))
        assertNotEquals(byeDpiEnvKey(home), byeDpiEnvKey(home.copy(gateways = listOf("10.0.0.1"))))
    }

    @Test
    fun `env key is empty when the link is unknown`() {
        assertEquals("", byeDpiEnvKey(RcxNetworkFacts()))
    }

    @Test
    fun `app-owned flags are stripped from the strategy`() {
        val dropped = mutableListOf<String>()
        val stripped = stripAppOwnedArgs(
            listOf("-d1", "-p", "9050", "-i=0.0.0.0", "--port=1234", "-yX", "-s1"),
            dropped::add,
        )
        assertEquals(listOf("-d1", "-s1"), stripped)
        assertEquals(listOf("-p", "-i=0.0.0.0", "--port=1234", "-yX"), dropped)
    }

    @Test
    fun `help and version never reach the engine`() {
        val stripped = stripAppOwnedArgs(listOf("-h", "-d1", "--help", "--version"))
        assertEquals(listOf("-d1"), stripped)
    }

    @Test
    fun `backoff grows and is capped`() {
        assertEquals(1_000L, ByeDpiPolicy.backoffMs(0))
        assertEquals(2_000L, ByeDpiPolicy.backoffMs(1))
        assertEquals(ByeDpiPolicy.MAX_BACKOFF_MS, ByeDpiPolicy.backoffMs(9))
    }
}
