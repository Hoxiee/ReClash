package com.reclash.widgets

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetTrafficTest {
    @Test
    fun `the ring buffer keeps the newest samples and drops the rest`() {
        val history = WidgetTrafficHistory(capacity = 3)

        (1L..5L).forEach { history.push(it, it * 10L) }

        assertEquals(3, history.size)
        assertEquals(listOf(3L, 4L, 5L), history.upSeries())
        assertEquals(listOf(30L, 40L, 50L), history.downSeries())
    }

    @Test
    fun `a negative reading from a core restart never dents the chart`() {
        val history = WidgetTrafficHistory(capacity = 4)

        history.push(-1L, -2L)

        assertEquals(listOf(0L), history.upSeries())
        assertEquals(listOf(0L), history.downSeries())
    }

    @Test
    fun `clearing leaves nothing for the next session to inherit`() {
        val history = WidgetTrafficHistory(capacity = 4)
        history.push(1L, 1L)

        history.clear()

        assertEquals(0, history.size)
        assertTrue(history.upSeries().isEmpty())
        assertTrue(history.downSeries().isEmpty())
    }

    @Test
    fun `the default history spans a minute of one second samples`() {
        assertEquals(60, trafficHistorySize)
    }

    @Test
    fun `a floor keeps idle kilobytes from being drawn as a mountain`() {
        assertEquals(65_536L, sparklinePeak(emptyList(), emptyList()))
        assertEquals(65_536L, sparklinePeak(listOf(10L), listOf(20L)))
        assertEquals(200_000L, sparklinePeak(listOf(200_000L), listOf(20L)))
        assertEquals(200_000L, sparklinePeak(listOf(20L), listOf(200_000L)))
    }

    @Test
    fun `an empty or collapsed canvas yields no points at all`() {
        assertEquals(0, sparklinePoints(emptyList(), 10f, 10f, 100L).size)
        assertEquals(0, sparklinePoints(listOf(1L), 0f, 10f, 100L).size)
        assertEquals(0, sparklinePoints(listOf(1L), 10f, 0f, 100L).size)
    }

    @Test
    fun `a single sample sits in the middle of the canvas`() {
        val points = sparklinePoints(listOf(50L), 10f, 20f, 100L)

        assertArrayEquals(floatArrayOf(5f, 10f), points, 0.001f)
    }

    @Test
    fun `the series spans the canvas and clamps above the peak`() {
        val points = sparklinePoints(listOf(0L, 50L, 400L), 10f, 20f, 100L)

assertArrayEquals(floatArrayOf(0f, 20f, 5f, 10f, 10f, 0f), points, 0.001f)
    }
}
