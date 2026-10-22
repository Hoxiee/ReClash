package com.reclash.service.modules

import com.reclash.service.models.NotificationComponent
import com.reclash.service.models.NotificationParams
import com.reclash.service.models.NotificationSettings
import com.reclash.service.models.Traffic
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class NotificationContentTest {
    @Test
    fun respectsOrderAndOmitsIdleSpeedAndMissingServer() {
        val params = NotificationParams(activeText = "Active", settings = NotificationSettings(components = listOf(
            NotificationComponent("sessionTraffic"), NotificationComponent("currentServer"), NotificationComponent("speed"),
        )))
        val lines = params.projectContent("Node", Traffic(0, 0), Traffic(up = 1, down = 2)).lines()
        assertTrue(lines.first().startsWith("Session traffic"))
        assertEquals("Current server · Node", lines.last())
        assertEquals(2, lines.size)
        assertEquals("Active", params.copy(settings = NotificationSettings(components = listOf(NotificationComponent("speed"))))
            .projectContent(null, Traffic(0, 0), null))
    }

    @Test
    fun minimalAndStaticContentsDoNotPoll() {
        assertNull(NotificationParams(settings = NotificationSettings(visibility = "minimal")).updateIntervalMillis)
        assertNull(NotificationParams(settings = NotificationSettings(components = emptyList())).updateIntervalMillis)
        assertNull(NotificationParams(settings = NotificationSettings(components = listOf(NotificationComponent("currentServer")))).updateIntervalMillis)
        assertEquals(2000L, NotificationParams(serverGroup = "Auto", settings = NotificationSettings(components = listOf(NotificationComponent("currentServer")))).updateIntervalMillis)
        assertEquals(1000L, NotificationParams().updateIntervalMillis)
    }

    @Test
    fun screenOffStopsTicksWhileSettingsStillArrive() = runTest {
        val params = MutableStateFlow(NotificationParams())
        val screen = MutableStateFlow(true)
        val emissions = mutableListOf<NotificationParams>()
        backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) {
            notificationUpdates(params, screen).collect { emissions.add(it) }
        }
        runCurrent()
        val before = emissions.size
        advanceTimeBy(3001)
        runCurrent()
        assertTrue(emissions.size > before)
        screen.value = false
        runCurrent()
        val off = emissions.size
        advanceTimeBy(5000)
        runCurrent()
        assertEquals(off, emissions.size)
        params.value = params.value.copy(title = "Changed")
        runCurrent()
        assertEquals("Changed", emissions.last().title)
        screen.value = true
        runCurrent()
        val awake = emissions.size
        advanceTimeBy(1001)
        runCurrent()
        assertTrue(emissions.size > awake)
        params.value = params.value.copy(settings = NotificationSettings(visibility = "minimal"))
        runCurrent()
        val minimal = emissions.size
        advanceTimeBy(5000)
        runCurrent()
        assertEquals(minimal, emissions.size)
    }
}
