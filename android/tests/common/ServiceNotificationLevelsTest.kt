package com.reclash.common

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test

// A foreground service must post and the app cannot hide the notification, so the
// level is a content choice on one channel; the retired per-level channels are
// deleted on startup.
class ServiceNotificationLevelsTest {
    @Test
    fun `the service owns a single channel and id`() {
        assertEquals("ReClash", GlobalState.NOTIFICATION_CHANNEL)
        assertEquals(1, GlobalState.NOTIFICATION_ID)
    }

    @Test
    fun `the retired per-level channels are marked stale for deletion`() {
        assertEquals(
            listOf("ReClash.quiet", "ReClash.off"),
            GlobalState.STALE_NOTIFICATION_CHANNELS,
        )
        assertFalse(GlobalState.NOTIFICATION_CHANNEL in GlobalState.STALE_NOTIFICATION_CHANNELS)
    }
}
