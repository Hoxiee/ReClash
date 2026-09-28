package com.reclash.service.modules

import org.junit.Assert.assertEquals
import org.junit.Test

class ScreenStateTest {

    @Test
    fun `the display state decides screen-on when it is readable`() {
        assertEquals(true, resolveScreenOn(mainDisplayOn = true, interactive = false))
        assertEquals(false, resolveScreenOn(mainDisplayOn = false, interactive = true))
    }

    @Test
    fun `an unreadable display falls back to the interactive flag`() {
        assertEquals(true, resolveScreenOn(mainDisplayOn = null, interactive = true))
        assertEquals(false, resolveScreenOn(mainDisplayOn = null, interactive = false))
    }
}
