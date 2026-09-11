package com.reclash.widgets

import org.junit.Assert.assertEquals
import org.junit.Test

class WidgetFormatTest {
    @Test
    fun `byte sizes climb units and stop at terabytes`() {
        assertEquals("0 B", formatBytes(0L))
        assertEquals("0 B", formatBytes(-1L))
        assertEquals("512 B", formatBytes(512L))
        assertEquals("1.0 KB", formatBytes(1024L))
        assertEquals("1.5 KB", formatBytes(1536L))
        assertEquals("1.0 MB", formatBytes(1024L * 1024L))
        assertEquals("1.0 TB", formatBytes(1024L * 1024L * 1024L * 1024L))
        assertEquals("1024.0 TB", formatBytes(1024L * 1024L * 1024L * 1024L * 1024L))
    }

    @Test
    fun `speed reuses the size scale`() {
        assertEquals("0 B/s", formatSpeed(0L))
        assertEquals("1.0 KB/s", formatSpeed(1024L))
    }

    @Test
    fun `uptime only grows an hour field once it has hours`() {
        assertEquals("00:00", formatUptime(0L))
        assertEquals("00:00", formatUptime(-5_000L))
        assertEquals("00:59", formatUptime(59_000L))
        assertEquals("01:01", formatUptime(61_000L))
        assertEquals("1:00:00", formatUptime(3_600_000L))
        assertEquals("12:01:01", formatUptime(43_261_000L))
    }

    @Test
    fun `an unmeasured node stays neutral instead of looking healthy`() {
        assertEquals(DelayGrade.NONE, delayGradeOf(0))
        assertEquals(DelayGrade.GOOD, delayGradeOf(1))
        assertEquals(DelayGrade.GOOD, delayGradeOf(599))
        assertEquals(DelayGrade.MEDIUM, delayGradeOf(600))
        assertEquals(DelayGrade.BAD, delayGradeOf(-1))

        assertEquals("", formatDelay(0))
        assertEquals("120 ms", formatDelay(120))
        assertEquals("--", formatDelay(-1))
    }

    @Test
    fun `shortening keeps the limit and never leaves a dangling space`() {
        assertEquals("abcdef", shorten("abcdef", 6))
        assertEquals("abcde…", shorten("abcdefg", 6))
        assertEquals("ab…", shorten("ab cdefg", 4))
        assertEquals(6, shorten("abcdefghij", 6).length)
    }
}
