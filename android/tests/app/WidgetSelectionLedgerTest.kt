package com.reclash.widgets

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetSelectionLedgerTest {
    private var stored: String? = null
    private var tokenIndex = 0
    private val ledger = WidgetSelectionLedger(
        read = { stored },
        write = { value ->
            stored = value
            true
        },
        nextToken = { "token-${++tokenIndex}" },
    )

    @Test
    fun `peek keeps a batch durable until its matching ack`() {
        assertTrue(ledger.record("proxy", "node-a"))
        val first = ledger.peek()!!

        assertEquals(mapOf("proxy" to "node-a"), first.selections)
        assertEquals(first, ledger.peek())
        assertFalse(ledger.acknowledge("another-token"))
        assertEquals(first, ledger.peek())
        assertTrue(ledger.acknowledge(first.token))
        assertNull(ledger.peek())
    }

    @Test
    fun `a newer selection invalidates an in flight ack`() {
        assertTrue(ledger.record("proxy", "node-a"))
        val inFlight = ledger.peek()!!

        assertTrue(ledger.record("proxy", "node-b"))
        val newer = ledger.peek()!!

        assertNotEquals(inFlight.token, newer.token)
        assertEquals(mapOf("proxy" to "node-b"), newer.selections)
        assertFalse(ledger.acknowledge(inFlight.token))
        assertEquals(newer, ledger.peek())
    }

    @Test
    fun `legacy pending selections survive migration until ack`() {
        stored = "{\"proxy\":\"node-a\"}"

        val legacy = ledger.peek()!!

        assertEquals("legacy", legacy.token)
        assertEquals(mapOf("proxy" to "node-a"), legacy.selections)
        assertTrue(ledger.acknowledge("legacy"))
        assertNull(ledger.peek())
    }
}
