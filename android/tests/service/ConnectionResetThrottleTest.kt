package com.reclash.service.modules

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ConnectionResetThrottleTest {

    private val window = 5_000L
    private val throttle = ConnectionResetThrottle(window)

    @Test
    fun `the first handover resets immediately`() {
        assertEquals(ResetPlan(ResetAction.NOW), throttle.request(1_000))
    }

    @Test
    fun `a second handover inside the window defers to the window edge`() {
        throttle.request(1_000)
        assertEquals(ResetPlan(ResetAction.DEFER, 4_000), throttle.request(2_000))
    }

    @Test
    fun `further handovers collapse into the pending one`() {
        throttle.request(1_000)
        throttle.request(2_000)
        assertEquals(ResetPlan(ResetAction.COALESCE), throttle.request(2_500))
        assertEquals(ResetPlan(ResetAction.COALESCE), throttle.request(3_000))
    }

    @Test
    fun `firing the deferred reset opens the next window from that moment`() {
        throttle.request(1_000)
        throttle.request(2_000)
        assertTrue(throttle.fire(5_000))
        assertEquals(ResetPlan(ResetAction.DEFER, 4_000), throttle.request(6_000))
    }

    @Test
    fun `there is nothing to fire without a deferred reset`() {
        assertFalse(throttle.fire(1_000))
        throttle.request(1_000)
        assertFalse(throttle.fire(1_500))
    }

    @Test
    fun `a handover after the window resets immediately again`() {
        throttle.request(1_000)
        assertEquals(ResetPlan(ResetAction.NOW), throttle.request(6_000))
    }

    @Test
    fun `stopping the observer clears the window`() {
        throttle.request(1_000)
        throttle.request(2_000)
        throttle.reset()
        assertEquals(ResetPlan(ResetAction.NOW), throttle.request(2_100))
    }

    @Test
    fun `the window is short enough to feel like a reconnect`() {
        assertTrue(ConnectionResetPolicy.WINDOW_MS in 1_000..10_000)
    }
}
