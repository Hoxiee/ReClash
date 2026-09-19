package com.reclash.widgets

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetSizeTest {
    @Test
    fun `width buckets follow the launcher cell grid`() {
        assertEquals(WidgetWidth.TINY, WidgetBox(40, 48).width)
        assertEquals(WidgetWidth.SMALL, WidgetBox(110, 48).width)
        assertEquals(WidgetWidth.MEDIUM, WidgetBox(180, 48).width)
        assertEquals(WidgetWidth.WIDE, WidgetBox(250, 48).width)
    }

    @Test
    fun `height buckets separate a single row from a stacked one`() {
        assertEquals(WidgetHeight.COMPACT, WidgetBox(180, 48).height)
        assertEquals(WidgetHeight.SHORT, WidgetBox(180, 110).height)
        assertEquals(WidgetHeight.TALL, WidgetBox(180, 180).height)
    }

    @Test
    fun `optional rows appear only once their own height is there`() {
        val short = WidgetBox(250, 110)
        val tall = WidgetBox(250, 180)

        assertFalse(short.metricsFit)
        assertFalse(short.chipsFit)

        assertTrue(tall.metricsFit)
        assertTrue(tall.chipsFit)
    }

    @Test
    fun `the node list always keeps at least one row and never runs away`() {
        assertEquals(1, WidgetBox(180, 48).nodeRows)
        assertEquals(1, WidgetBox(180, 110).nodeRows)
        assertEquals(3, WidgetBox(180, 180).nodeRows)
        assertEquals(10, WidgetBox(180, 400).nodeRows)
        assertEquals(16, WidgetBox(180, 4000).nodeRows)
    }

    @Test
    fun `a launcher that reports nothing gets the declared minimum`() {
        val blind = widgetBoxOf(0, 0, fallbackWidthDp = 250, fallbackHeightDp = 110)
        val honest = widgetBoxOf(324, 276, fallbackWidthDp = 250, fallbackHeightDp = 110)

        assertEquals(WidgetBox(250, 110), blind)
        assertEquals(WidgetBox(324, 276), honest)
    }
}
