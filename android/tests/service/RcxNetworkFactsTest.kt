package com.reclash.service.modules

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class RcxNetworkFactsTest {

    @Test
    fun `json field names match the core payload`() {
        val json = RcxNetworkFacts(
            transport = "wifi",
            ssid = "Home",
            gateways = listOf("192.168.1.1"),
            dhcp = "192.168.1.1",
            dns = listOf("192.168.1.1", "1.1.1.1"),
            ipv4 = listOf("192.168.1.55"),
            validated = true,
            metered = false,
        ).toJson()

        assertEquals(
            """{"transport":"wifi","ssid":"Home","carrier":"",""" +
                """"gateways":["192.168.1.1"],"dhcp":"192.168.1.1",""" +
                """"dns":["192.168.1.1","1.1.1.1"],"ipv4":["192.168.1.55"],""" +
                """"validated":true,"portal":false,"metered":false}""",
            json,
        )
    }

    @Test
    fun `an ssid cannot break out of the json string`() {
        val json = RcxNetworkFacts(transport = "wifi", ssid = """Cafe "free"\wifi""").toJson()

        assertTrue(json, json.contains("""\"free\"\\wifi"""))
    }

    @Test
    fun `control characters are escaped rather than emitted raw`() {
        assertEquals("""a\nb""", rcxEscapeJson("a\nb"))
        assertEquals("""\u0007""", rcxEscapeJson("\u0007"))
    }

    @Test
    fun `equal facts compare equal so an unchanged network sends nothing`() {
        val first = RcxNetworkFacts(transport = "cellular", carrier = "25001")
        val second = RcxNetworkFacts(transport = "cellular", carrier = "25001")

        assertEquals(first, second)
    }
}
