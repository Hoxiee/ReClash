package com.reclash.service.modules

import com.reclash.service.DoctorStatus
import com.reclash.service.PauseState
import com.reclash.service.SmartRoutingStatus
import com.reclash.service.models.NotificationComponent
import com.reclash.service.models.NotificationParams
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class NotificationModuleTest {
    private fun serverParams() = NotificationParams(
        title = "Private profile",
        visibility = "detailed",
        activeText = "Private provider caption",
        neutralActiveText = "Protection enabled",
        activeServerGroup = "Proxy",
        components = listOf(NotificationComponent(type = "currentServer")),
    )

    @Test
    fun `minimal and legacy hidden levels expose only neutral status`() {
        for (visibility in listOf("minimal", "off")) {
            var resolved = false
            val params = serverParams().copy(visibility = visibility)
            val projected = params.extended(
                paused = false,
                routing = SmartRoutingStatus(enabled = true, node = "Private server"),
                doctor = DoctorStatus(health = "broken"),
                activeServerResolver = {
                    resolved = true
                    "Private server"
                },
            )

            assertEquals("ReClash", projected.title)
            assertEquals("Protection enabled", projected.contentText)
            assertEquals("Protection enabled", projected.publicContentText)
            assertFalse(projected.showPauseAction)
            assertFalse(projected.showStopAction)
            assertFalse(resolved)
            assertNull(params.updateIntervalMillis)
        }
    }

    @Test
    fun `detailed content keeps provider text out of its public version`() {
        val params = serverParams().copy(components = emptyList())
        val active = params.extended(false, SmartRoutingStatus(), DoctorStatus())
        val paused = params.extended(true, SmartRoutingStatus(), DoctorStatus())

        assertEquals("Private profile", active.title)
        assertEquals("Private provider caption", active.contentText)
        assertEquals("Protection enabled", active.publicContentText)
        assertEquals("Paused", paused.contentText)
        assertEquals("Paused", paused.publicContentText)
        assertEquals(true, paused.showPauseAction)
    }

    @Test
    fun `privacy changes remain observable without a timer or content change`() {
        val params = serverParams().copy(components = emptyList())
        val hidden = params.extended(false, SmartRoutingStatus(), DoctorStatus())
        val visible = params.copy(hideSensitiveOnLockScreen = false)
            .extended(false, SmartRoutingStatus(), DoctorStatus())

        assertEquals(hidden.contentText, visible.contentText)
        assertNotEquals(hidden, visible)
        assertEquals(true, hidden.hideSensitiveOnLockScreen)
        assertEquals(false, visible.hideSensitiveOnLockScreen)
    }

    @Test
    fun `current server uses the resolved group rather than an obsolete override`() {
        val queries = mutableListOf<String>()
        val params = serverParams().copy(
            activeServerGroup = "  Resolved  ",
            components = listOf(NotificationComponent(type = "currentServer", group = "Missing")),
        )
        val resolve: (String) -> String? = { group ->
            queries += group
            "Node"
        }

        assertEquals("Node", params.resolveActiveServer(resolve))
        assertEquals(listOf("Resolved"), queries)
        assertNull(params.copy(activeServerGroup = null).resolveActiveServer(resolve))
        assertNull(params.copy(activeServerGroup = "  ").resolveActiveServer(resolve))
        assertNull(params.copy(components = emptyList()).resolveActiveServer(resolve))
        assertEquals(listOf("Resolved"), queries)
        assertNull(params.resolveActiveServer { error("Core unavailable") })
    }

    @Test
    fun `current server follows automatic switches and wakes without counters`() = runTest {
        val params = MutableStateFlow(serverParams())
        val pause = MutableStateFlow(PauseState())
        val screenOn = MutableStateFlow(true)
        val routing = MutableStateFlow(SmartRoutingStatus())
        val doctor = MutableStateFlow(DoctorStatus())
        val shown = mutableListOf<ExtendedNotificationParams>()
        var node = "A"
        var reads = 0
        backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) {
            notificationUpdates(params, pause, routing, doctor, screenOn) {
                reads++
                node
            }.collect { shown += it }
        }
        runCurrent()
        assertEquals("Current server · A", shown.last().contentText)

        node = "B"
        advanceTimeBy(1_999)
        runCurrent()
        assertEquals("Current server · A", shown.last().contentText)
        advanceTimeBy(1)
        runCurrent()
        assertEquals("Current server · B", shown.last().contentText)

        screenOn.value = false
        runCurrent()
        val readsWhileOff = reads
        node = "C"
        advanceTimeBy(20_000)
        runCurrent()
        assertEquals(readsWhileOff, reads)
        screenOn.value = true
        runCurrent()
        assertEquals("Current server · C", shown.last().contentText)

        pause.value = PauseState(paused = true)
        runCurrent()
        assertEquals("Paused", shown.last().contentText)
        assertEquals("Paused", shown.last().publicContentText)
        val readsWhilePaused = reads
        node = "D"
        advanceTimeBy(20_000)
        runCurrent()
        assertEquals(readsWhilePaused, reads)
        pause.value = PauseState()
        runCurrent()
        assertEquals("Current server · D", shown.last().contentText)

        params.value = params.value.copy(visibility = "minimal")
        runCurrent()
        val readsWhileMinimal = reads
        node = "E"
        advanceTimeBy(20_000)
        runCurrent()
        assertEquals(readsWhileMinimal, reads)
        assertEquals("ReClash", shown.last().title)
        assertEquals("Protection enabled", shown.last().contentText)
        params.value = serverParams()
        runCurrent()
        assertEquals("Current server · E", shown.last().contentText)
    }

    @Test
    fun `Core status events still refresh the server while the screen is off`() = runTest {
        val params = MutableStateFlow(serverParams())
        val pause = MutableStateFlow(PauseState())
        val routing = MutableStateFlow(SmartRoutingStatus())
        val doctor = MutableStateFlow(DoctorStatus())
        val shown = mutableListOf<ExtendedNotificationParams>()
        var node = "A"
        backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) {
            notificationUpdates(params, pause, routing, doctor, MutableStateFlow(false)) {
                node
            }.collect { shown += it }
        }
        runCurrent()
        node = "B"
        doctor.value = DoctorStatus(revision = 1)
        runCurrent()
        assertEquals("Current server · B", shown.last().contentText)
        node = "C"
        routing.value = SmartRoutingStatus(enabled = true, node = "C")
        runCurrent()
        assertEquals("Current server · C", shown.last().contentText)
    }

    @Test
    fun `counter cadence changes to server cadence when counters are removed`() = runTest {
        val params = MutableStateFlow(
            serverParams().copy(components = listOf(NotificationComponent(type = "speed"))),
        )
        val ticks = mutableListOf<Long>()
        backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) {
            notificationTicks(params, MutableStateFlow(PauseState()), MutableStateFlow(true))
                .collect { ticks += testScheduler.currentTime }
        }
        runCurrent()
        assertEquals(listOf(0L), ticks)
        advanceTimeBy(1_000)
        runCurrent()
        assertEquals(listOf(0L, 1_000L), ticks)

        params.value = serverParams()
        runCurrent()
        val afterChange = ticks.size
        advanceTimeBy(1_999)
        runCurrent()
        assertEquals(afterChange, ticks.size)
        advanceTimeBy(1)
        runCurrent()
        assertEquals(3_000L, ticks.last())
        assertEquals(afterChange + 1, ticks.size)
    }
}
