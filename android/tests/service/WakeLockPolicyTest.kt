package com.reclash.service.modules

import org.junit.Assert.assertEquals
import org.junit.Test

class WakeLockPolicyTest {

    @Test
    fun `screen off grants the settle grace once`() {
        assertEquals(
            WakeLockAction.Acquire,
            wakeLockAction(screenOn = false, deviceIdle = false, paused = false, graceConsumed = false),
        )
    }

    @Test
    fun `a spent grace is not renewed while the screen stays off`() {
        assertEquals(
            WakeLockAction.Leave,
            wakeLockAction(screenOn = false, deviceIdle = false, paused = false, graceConsumed = true),
        )
    }

    @Test
    fun `an interactive screen already keeps the cpu awake`() {
        assertEquals(
            WakeLockAction.Release,
            wakeLockAction(screenOn = true, deviceIdle = false, paused = false, graceConsumed = false),
        )
    }

    @Test
    fun `doze ignores partial locks so the lock is dropped`() {
        assertEquals(
            WakeLockAction.Release,
            wakeLockAction(screenOn = false, deviceIdle = true, paused = false, graceConsumed = false),
        )
    }

    @Test
    fun `a paused tunnel carries no traffic to keep alive`() {
        assertEquals(
            WakeLockAction.Release,
            wakeLockAction(screenOn = false, deviceIdle = false, paused = true, graceConsumed = false),
        )
    }

    @Test
    fun `the grace window covers a short transfer without spanning standby`() {
        assertEquals(120_000L, WakeLockPolicy.GRACE_MS)
    }
}
