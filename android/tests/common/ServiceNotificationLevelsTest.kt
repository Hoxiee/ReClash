package com.reclash.common

import android.app.NotificationManager
import org.junit.Assert.assertEquals
import org.junit.Test

// Channel importance is immutable after creation and ActivityManagerService only drops the previous
// foreground notification when the id changes, so both mappings are platform contracts.
class ServiceNotificationLevelsTest {
    private val channels = listOf(
        GlobalState.NOTIFICATION_CHANNEL,
        GlobalState.NOTIFICATION_CHANNEL_QUIET,
        GlobalState.NOTIFICATION_CHANNEL_HIDDEN,
    )

    @Test
    fun `each level owns the channel id the Dart layer deep-links to`() {
        assertEquals(listOf("ReClash", "ReClash.quiet", "ReClash.off"), channels)
    }

    @Test
    fun `importance falls to none on the hidden channel`() {
        assertEquals(
            listOf(
                NotificationManager.IMPORTANCE_LOW,
                NotificationManager.IMPORTANCE_MIN,
                NotificationManager.IMPORTANCE_NONE,
            ),
            channels.map(::serviceChannelImportance),
        )
    }

    @Test
    fun `each level owns a notification id of its own`() {
        val ids = channels.map(::serviceNotificationId)
        assertEquals(listOf(1, 2, 3), ids)
        assertEquals(ids.size, ids.toSet().size)
    }

    @Test
    fun `each level names its own channel`() {
        val names = channels.map(::serviceChannelName)
        assertEquals(
            listOf(
                R.string.service_channel_name,
                R.string.service_channel_quiet_name,
                R.string.service_channel_hidden_name,
            ),
            names,
        )
    }

    @Test
    fun `an unknown channel stays on the visible level`() {
        assertEquals(
            NotificationManager.IMPORTANCE_LOW,
            serviceChannelImportance("ReClash.stale"),
        )
        assertEquals(GlobalState.NOTIFICATION_ID, serviceNotificationId("ReClash.stale"))
        assertEquals(R.string.service_channel_name, serviceChannelName("ReClash.stale"))
    }
}
