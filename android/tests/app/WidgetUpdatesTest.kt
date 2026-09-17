package com.reclash.widgets

import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class WidgetUpdatesTest {
    private class Pump(
        scope: TestScope,
        awake: Boolean = true,
        present: Boolean = true,
        live: Boolean = true,
    ) {
        val revision = MutableStateFlow(0)
        val running = MutableStateFlow(live)
        val interactive = MutableStateFlow(awake)
        val installed = MutableStateFlow(present)
        val renders = mutableListOf<Int>()

        init {
            scope.backgroundScope.launch {
                widgetUpdates(
                    updates = revision.map { Unit },
                    running = running,
                    interactive = interactive,
                    installed = installed,
                    tickMillis = 1_000L,
                ).collect { renders.add(revision.value) }
            }
        }
    }

    @Test
    fun `no placements means no state subscriptions or ticks`() = runTest {
        val pump = Pump(this, present = false)
        runCurrent()

        assertEquals(0, pump.revision.subscriptionCount.value)
        assertEquals(0, pump.running.subscriptionCount.value)
        pump.revision.value++
        advanceTimeBy(5_000L)
        runCurrent()
        assertTrue(pump.renders.isEmpty())
    }

    @Test
    fun `screen off at startup does not subscribe or render`() = runTest {
        val pump = Pump(this, awake = false)
        runCurrent()

        assertEquals(0, pump.revision.subscriptionCount.value)
        assertEquals(0, pump.running.subscriptionCount.value)
        pump.revision.value++
        advanceTimeBy(5_000L)
        runCurrent()
        assertTrue(pump.renders.isEmpty())
    }

    @Test
    fun `screen off cancels ticks and events until wake`() = runTest {
        val pump = Pump(this)
        runCurrent()
        assertEquals(listOf(0), pump.renders)

        pump.interactive.value = false
        runCurrent()
        assertEquals(0, pump.revision.subscriptionCount.value)
        assertEquals(0, pump.running.subscriptionCount.value)
        pump.revision.value = 1
        runCurrent()
        pump.revision.value = 2
        advanceTimeBy(5_000L)
        runCurrent()
        assertEquals(listOf(0), pump.renders)

        pump.interactive.value = true
        runCurrent()
        assertEquals(listOf(0, 2), pump.renders)
        advanceTimeBy(1_000L)
        runCurrent()
        assertEquals(listOf(0, 2, 2), pump.renders)
    }

    @Test
    fun `wake refreshes stopped widgets without starting a ticker`() = runTest {
        val pump = Pump(this, awake = false, live = false)
        runCurrent()
        pump.revision.value = 7
        pump.interactive.value = true
        runCurrent()
        assertEquals(listOf(7), pump.renders)

        advanceTimeBy(5_000L)
        runCurrent()
        assertEquals(listOf(7), pump.renders)
        pump.revision.value = 8
        runCurrent()
        assertEquals(listOf(7, 8), pump.renders)
    }

    @Test
    fun `removing and adding placements restarts with current state`() = runTest {
        val pump = Pump(this)
        runCurrent()
        pump.installed.value = false
        runCurrent()
        assertEquals(0, pump.revision.subscriptionCount.value)
        assertEquals(0, pump.running.subscriptionCount.value)
        pump.revision.value = 4
        advanceTimeBy(5_000L)
        runCurrent()
        assertEquals(listOf(0), pump.renders)

        pump.installed.value = true
        runCurrent()
        assertEquals(listOf(0, 4), pump.renders)
        assertEquals(1, pump.revision.subscriptionCount.value)
        assertEquals(1, pump.running.subscriptionCount.value)
    }

    @Test
    fun `visible running widgets tick and stopping cancels periodic work`() = runTest {
        val pump = Pump(this)
        runCurrent()
        advanceTimeBy(2_000L)
        runCurrent()
        assertEquals(listOf(0, 0, 0), pump.renders)

        pump.running.value = false
        runCurrent()
        assertEquals(listOf(0, 0, 0, 0), pump.renders)
        advanceTimeBy(5_000L)
        runCurrent()
        assertEquals(listOf(0, 0, 0, 0), pump.renders)
        pump.revision.value = 1
        runCurrent()
        assertEquals(listOf(0, 0, 0, 0, 1), pump.renders)
    }
}
