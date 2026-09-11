package com.reclash.service

import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class TunLifecycleTest {

    @Test
    fun `a stop that overtakes a start remains the final writer`() {
        val lifecycle = TunLifecycle()
        val startEntered = CountDownLatch(1)
        val releaseStart = CountDownLatch(1)
        val calls = mutableListOf<String>()
        val startThread = thread {
            assertTrue(
                lifecycle.start(
                    start = {
                        startEntered.countDown()
                        assertTrue(releaseStart.await(5, TimeUnit.SECONDS))
                        calls += "start"
                    },
                    rollback = { calls += "rollback" },
                ),
            )
        }
        assertTrue(startEntered.await(5, TimeUnit.SECONDS))

        lifecycle.beginStop()
        val stopThread = thread {
            lifecycle.stop { calls += "stop" }
        }
        releaseStart.countDown()
        startThread.join()
        stopThread.join()

        assertEquals(listOf("start", "stop"), calls)
        assertFalse(lifecycle.start(start = {}, rollback = {}))
    }

    @Test
    fun `a start rejected after teardown never invokes core`() {
        val lifecycle = TunLifecycle()
        var starts = 0
        lifecycle.beginStop()

        val started = lifecycle.start(
            start = { starts++ },
            rollback = {},
        )

        assertFalse(started)
        assertEquals(0, starts)
    }
}
