package com.reclash.service.models

import com.reclash.common.AccessControlMode
import java.net.Inet4Address
import java.net.Inet6Address
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

private fun optionsWithRoutes(routeAddress: List<String>) = VpnOptions(
    enable = true,
    port = 7890,
    ipv6 = true,
    dnsHijacking = false,
    accessControlProps = AccessControlProps(
        enable = false,
        mode = AccessControlMode.ACCEPT_SELECTED,
        acceptList = emptyList(),
        rejectList = emptyList(),
    ),
    allowBypass = false,
    systemProxy = true,
    bypassDomain = emptyList(),
    stack = "gvisor",
    routeAddress = routeAddress,
)

class ToCIDRTest {
    @Test
    fun `parses an IPv4 network`() {
        val cidr = "192.168.1.0/24".toCIDR()

        assertTrue(cidr.address is Inet4Address)
        assertEquals("192.168.1.0", cidr.address.hostAddress)
        assertEquals(24, cidr.prefixLength)
    }

    @Test
    fun `parses an IPv6 network`() {
        val cidr = "fd00::/8".toCIDR()

        assertTrue(cidr.address is Inet6Address)
        assertEquals(8, cidr.prefixLength)
    }

    @Test
    fun `accepts the boundary prefix lengths`() {
        assertEquals(0, "0.0.0.0/0".toCIDR().prefixLength)
        assertEquals(32, "10.0.0.1/32".toCIDR().prefixLength)
        assertEquals(0, "::/0".toCIDR().prefixLength)
        assertEquals(128, "fd00::1/128".toCIDR().prefixLength)
    }

    @Test
    fun `rejects an address without a prefix`() {
        val error = assertThrows(IllegalArgumentException::class.java) {
            "192.168.1.0".toCIDR()
        }
        assertTrue(error.message!!.contains("Invalid CIDR format"))
    }

    @Test
    fun `rejects an address with too many segments`() {
        assertThrows(IllegalArgumentException::class.java) {
            "192.168.1.0/24/8".toCIDR()
        }
    }

    @Test
    fun `rejects a non-numeric prefix`() {
        val error = assertThrows(IllegalArgumentException::class.java) {
            "192.168.1.0/abc".toCIDR()
        }
        assertTrue(error.message!!.contains("Invalid prefix length"))
    }

    @Test
    fun `rejects an IPv4 prefix above 32`() {
        assertThrows(IllegalArgumentException::class.java) {
            "192.168.1.0/33".toCIDR()
        }
    }

    @Test
    fun `rejects an IPv6 prefix above 128`() {
        assertThrows(IllegalArgumentException::class.java) {
            "fd00::/129".toCIDR()
        }
    }

    @Test
    fun `rejects a negative prefix`() {
        assertThrows(IllegalArgumentException::class.java) {
            "192.168.1.0/-1".toCIDR()
        }
    }
}

class RouteAddressTest {
    @Test
    fun `splits a mixed route list by address family`() {
        val options = optionsWithRoutes(
            listOf("192.168.1.0/24", "fd00::/8", "10.0.0.0/8", "2000::/3"),
        )

        val ipv4 = options.getIpv4RouteAddress()
        val ipv6 = options.getIpv6RouteAddress()

        assertEquals(2, ipv4.size)
        assertEquals(2, ipv6.size)
        assertTrue(ipv4.all { it.address is Inet4Address })
        assertTrue(ipv6.all { it.address is Inet6Address })
    }

    @Test
    fun `returns empty lists for an empty route list`() {
        val options = optionsWithRoutes(emptyList())

        assertTrue(options.getIpv4RouteAddress().isEmpty())
        assertTrue(options.getIpv6RouteAddress().isEmpty())
    }

    @Test
    fun `preserves the configured order within a family`() {
        val options = optionsWithRoutes(
            listOf("10.0.0.0/8", "fd00::/8", "192.168.0.0/16"),
        )

        assertEquals(
            listOf(8, 16),
            options.getIpv4RouteAddress().map { it.prefixLength },
        )
    }

    @Test
    fun `propagates a malformed entry instead of silently dropping it`() {
        val options = optionsWithRoutes(listOf("192.168.1.0/24", "not-a-cidr"))

        assertThrows(IllegalArgumentException::class.java) {
            options.getIpv4RouteAddress()
        }
    }
}

class RouteExcludeAddressTest {
    @Test
    fun `splits exclusions by address family`() {
        val options = optionsWithRoutes(emptyList())
            .copy(routeExcludeAddress = listOf("10.0.0.0/8", "fd00::/8"))

        assertEquals(1, options.getIpv4RouteExcludeAddress().size)
        assertEquals(1, options.getIpv6RouteExcludeAddress().size)
        assertTrue(options.getIpv4RouteExcludeAddress().all { it.address is Inet4Address })
        assertTrue(options.getIpv6RouteExcludeAddress().all { it.address is Inet6Address })
    }

    @Test
    fun `a malformed exclusion propagates instead of silently dropping`() {
        val options = optionsWithRoutes(emptyList())
            .copy(routeExcludeAddress = listOf("not-a-cidr"))

        assertThrows(IllegalArgumentException::class.java) {
            options.getIpv4RouteExcludeAddress()
        }
    }
}

class TunMtuTest {
    private fun optionsWithMtu(mtu: Int) = optionsWithRoutes(emptyList()).copy(mtu = mtu)

    @Test
    fun `an absent or non-positive mtu falls back to 1500`() {
        assertEquals(1500, optionsWithMtu(0).tunMtu)
        assertEquals(1500, optionsWithMtu(-1).tunMtu)
    }

    @Test
    fun `an mtu below the minimum clamps up to 1280`() {
        assertEquals(1280, optionsWithMtu(1000).tunMtu)
    }

    @Test
    fun `an mtu above the maximum clamps down to 65535`() {
        assertEquals(65535, optionsWithMtu(70000).tunMtu)
    }

    @Test
    fun `an in-range mtu is kept`() {
        assertEquals(1500, optionsWithMtu(1500).tunMtu)
        assertEquals(9000, optionsWithMtu(9000).tunMtu)
    }
}

class TunOptionsTest {
    private fun payloadOf(options: VpnOptions) = JSONObject(options.tunOptions())

    @Test
    fun `payload mtu agrees with tunMtu`() {
        val options = optionsWithRoutes(emptyList()).copy(mtu = 9000)
        val payload = payloadOf(options)

        assertEquals(options.tunMtu, payload.getInt("mtu"))
        assertEquals(9000, payload.getInt("mtu"))
    }

    @Test
    fun `a missing congestion controller defaults to cubic`() {
        val payload = payloadOf(optionsWithRoutes(emptyList()).copy(congestionController = null))

        assertEquals("cubic", payload.getString("congestion-controller"))
    }

    @Test
    fun `a blank congestion controller defaults to cubic`() {
        val payload = payloadOf(optionsWithRoutes(emptyList()).copy(congestionController = "  "))

        assertEquals("cubic", payload.getString("congestion-controller"))
    }

    @Test
    fun `an explicit congestion controller is passed through`() {
        val payload = payloadOf(optionsWithRoutes(emptyList()).copy(congestionController = "bbr3"))

        assertEquals("bbr3", payload.getString("congestion-controller"))
    }
}
