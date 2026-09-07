package com.reclash

import com.reclash.common.QuickAction
import org.junit.Assert.assertEquals
import org.junit.Test

class HomeWidgetPresentationTest {
    @Test
    fun `every run state maps to a widget presentation`() {
        val expected = mapOf(
            RunState.STARTED to (R.string.widget_connected to R.string.widget_stop),
            RunState.STARTING to (R.string.widget_connecting to R.string.widget_wait),
            RunState.STOPPING to (R.string.widget_disconnecting to R.string.widget_wait),
            RunState.STOPPED to (R.string.widget_disconnected to R.string.widget_start),
            RunState.PAUSED to (R.string.widget_paused to R.string.widget_resume),
        )

        expected.forEach { (state, labels) ->
            val presentation = state.toHomeWidgetPresentation()

            assertEquals(labels.first, presentation.statusRes)
            assertEquals(labels.second, presentation.actionLabelRes)
            assertEquals(QuickAction.TOGGLE, presentation.action)
        }
    }
}
