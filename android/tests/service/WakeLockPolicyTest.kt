package com.reclash.service.modules

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class WakeLockPolicyTest {

    @Test
    fun `holds the lock while the screen is off and the device is awake`() {
        assertTrue(shouldHoldWakeLock(screenOn = false, deviceIdle = false, paused = false))
    }

    @Test
    fun `an interactive screen already keeps the cpu awake`() {
        assertFalse(shouldHoldWakeLock(screenOn = true, deviceIdle = false, paused = false))
    }

    @Test
    fun `doze ignores partial locks so the lock is dropped`() {
        assertFalse(shouldHoldWakeLock(screenOn = false, deviceIdle = true, paused = false))
    }

    @Test
    fun `a paused tunnel carries no traffic to keep alive`() {
        assertFalse(shouldHoldWakeLock(screenOn = false, deviceIdle = false, paused = true))
    }

    @Test
    fun `the grace window covers a short transfer without spanning standby`() {
        assertEquals(120_000L, WakeLockPolicy.GRACE_MS)
    }
}
