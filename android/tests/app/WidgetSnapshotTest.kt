package com.reclash.widgets

import com.reclash.RunState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

private fun snapshot(
    runState: RunState = RunState.STARTED,
    searching: Boolean = false,
    doctorState: String = "",
    doctorHealth: String = "",
    byedpiOnly: Boolean = false,
    startedAtMillis: Long = 0L,
) = WidgetSnapshot(
    runState = runState,
    searching = searching,
    doctorState = doctorState,
    doctorHealth = doctorHealth,
    byedpiOnly = byedpiOnly,
    startedAtMillis = startedAtMillis,
)

class WidgetSnapshotTest {
    @Test
    fun `a paused tunnel still counts as live`() {
        assertTrue(snapshot(RunState.STARTED).live)
        assertTrue(snapshot(RunState.PAUSED).live)
        assertFalse(snapshot(RunState.STOPPED).live)
        assertFalse(snapshot(RunState.STARTING).live)
        assertFalse(snapshot(RunState.STOPPING).live)
    }

    @Test
    fun `a lifecycle transition outranks any health verdict`() {
        val broken = snapshot(RunState.STOPPED, doctorHealth = "broken")
        val paused = snapshot(RunState.PAUSED, doctorState = "examining")

        assertEquals(WidgetTone.IDLE, broken.tone)
        assertEquals(WidgetTone.PENDING, snapshot(RunState.STARTING).tone)
        assertEquals(WidgetTone.PENDING, snapshot(RunState.STOPPING).tone)
        assertEquals(WidgetTone.PAUSED, paused.tone)
    }

    @Test
    fun `an exam and a search both read as pending`() {
        assertEquals(WidgetTone.PENDING, snapshot(doctorState = "examining").tone)
        assertEquals(WidgetTone.PENDING, snapshot(searching = true).tone)
    }

    @Test
    fun `health decides the tone once nothing is in flight`() {
        assertEquals(WidgetTone.BROKEN, snapshot(doctorHealth = "broken").tone)
        assertEquals(WidgetTone.DEGRADED, snapshot(doctorHealth = "degraded").tone)
        assertEquals(WidgetTone.ACTIVE, snapshot(doctorHealth = "healthy").tone)
        assertEquals(WidgetTone.ACTIVE, snapshot().tone)
    }

    @Test
    fun `uptime is zero unless the tunnel is up with a known start`() {
        val started = System.currentTimeMillis() - 5_000L

        assertEquals(0L, snapshot(RunState.STARTED).uptimeMillis)
        assertEquals(0L, snapshot(RunState.STOPPED, startedAtMillis = started).uptimeMillis)
        assertTrue(snapshot(startedAtMillis = started).uptimeMillis >= 5_000L)
        assertTrue(snapshot(startedAtMillis = started).uptimeMillis < 60_000L)
    }

    @Test
    fun `the mode follows the byedpi-only flag`() {
        assertEquals(WidgetMode.VPN, snapshot().mode)
        assertEquals(WidgetMode.BYEDPI, snapshot(byedpiOnly = true).mode)
    }

    @Test
    fun `a clock that jumped backwards never shows a negative uptime`() {
        val future = System.currentTimeMillis() + 60_000L

        assertEquals(0L, snapshot(startedAtMillis = future).uptimeMillis)
    }
}
