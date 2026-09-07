package com.reclash

import androidx.annotation.StringRes
import com.reclash.common.QuickAction

data class HomeWidgetPresentation(
    @param:StringRes val statusRes: Int,
    @param:StringRes val actionLabelRes: Int,
    val action: QuickAction = QuickAction.TOGGLE,
)

fun RunState.toHomeWidgetPresentation(): HomeWidgetPresentation = when (this) {
    RunState.STARTED -> HomeWidgetPresentation(
        statusRes = R.string.widget_connected,
        actionLabelRes = R.string.widget_stop,
    )
    RunState.STARTING -> HomeWidgetPresentation(
        statusRes = R.string.widget_connecting,
        actionLabelRes = R.string.widget_wait,
    )
    RunState.STOPPING -> HomeWidgetPresentation(
        statusRes = R.string.widget_disconnecting,
        actionLabelRes = R.string.widget_wait,
    )
    RunState.STOPPED -> HomeWidgetPresentation(
        statusRes = R.string.widget_disconnected,
        actionLabelRes = R.string.widget_start,
    )
    RunState.PAUSED -> HomeWidgetPresentation(
        statusRes = R.string.widget_paused,
        actionLabelRes = R.string.widget_resume,
    )
}
