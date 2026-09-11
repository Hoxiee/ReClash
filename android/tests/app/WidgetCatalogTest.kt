package com.reclash.widgets

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

private const val proxiesJson = """
{
        "proxies": {
    "RCX-NODE": {"type": "Selector", "now": "Alpha", "all": ["Alpha", "Beta"]},
    "RCX-AUTO": {"type": "Selector", "now": "Alpha", "all": ["Alpha"]},
    "Manual": {"type": "URLTest", "now": "Beta", "all": ["Beta"]},
    "DIRECT": {"type": "Direct"},
    "Alpha": {"type": "Shadowsocks", "history": [{"delay": 90}, {"delay": 120}]},
    "Beta": {"type": "Shadowsocks", "history": []}
        },
        "all": ["RCX-NODE", "RCX-AUTO", "Manual", "DIRECT", "Alpha", "Missing"]
}
"""

private fun groups(): List<WidgetGroupView> =
    parseWidgetGroups(unwrapCoreResult("""{"id": "1", "result": $proxiesJson}"""))

private fun group(name: String, vararg nodes: String) =
    WidgetGroupView(name, nodes.firstOrNull().orEmpty(), nodes.map { WidgetNode(it, 0) })

class WidgetCatalogTest {
    @Test
    fun `an envelope carrying an error yields nothing`() {
        assertNull(unwrapCoreResult(null))
        assertNull(unwrapCoreResult(""))
        assertNull(unwrapCoreResult("not json"))
        assertNull(unwrapCoreResult("""{"id": "1", "result": null}"""))
        assertNull(unwrapCoreResult("""{"id": "1", "error": {"code": 3, "message": "no"}}"""))
    }

    @Test
    fun `a plain result comes back unwrapped`() {
        val result = unwrapCoreResult("""{"id": "1", "result": {"a": 1}}""")

        assertEquals(1, result?.asJsonObject?.get("a")?.asInt)
    }

    @Test
    fun `only groups a tap can actually change reach the list`() {
        assertEquals(listOf("RCX-NODE", "Manual"), groups().map { it.name })
    }

    @Test
    fun `a group carries its members and their last measured delay`() {
        val nodes = groups().first().nodes

        assertEquals(listOf("Alpha", "Beta"), nodes.map { it.name })
        assertEquals(120, nodes.first().delay)
        assertEquals(0, nodes.last().delay)
        assertEquals("Alpha", groups().first().now)
    }

    @Test
    fun `the remembered group wins whenever it is still there`() {
        assertEquals("Manual", pickWidgetGroup(groups(), "Manual")?.name)
        assertEquals("RCX-NODE", pickWidgetGroup(groups(), "Gone")?.name)
        assertEquals("RCX-NODE", pickWidgetGroup(groups(), "")?.name)
        assertEquals("RCX-NODE", pickWidgetGroup(groups(), null)?.name)
    }

    @Test
    fun `without a node group the widget falls back to a group worth tapping`() {
        val single = group("Single", "One")
        val many = group("Many", "One", "Two")

        assertNull(pickWidgetGroup(emptyList(), "Manual"))
        assertEquals("Many", pickWidgetGroup(listOf(single, many), null)?.name)
        assertEquals("Single", pickWidgetGroup(listOf(single), null)?.name)
    }
}
