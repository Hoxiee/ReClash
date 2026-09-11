package com.reclash.widgets

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.reclash.RunState
import com.reclash.common.Components
import com.reclash.common.QuickAction
import com.reclash.common.intent
import com.reclash.common.quickIntent
import com.reclash.common.toPendingIntent
import com.reclash.toHomeWidgetPresentation

internal object WidgetActions {
    const val EXAMINE = "WIDGET_EXAMINE"
    const val MEASURE = "WIDGET_MEASURE"
    const val SELECT = "WIDGET_SELECT"
    const val EXTRA_GROUP = "group"
    const val EXTRA_NODE = "node"

    private const val requestExamine = 0x5701
    private const val requestMeasure = 0x5702
    private const val requestSelect = 0x5703
    private const val requestOpen = 0x5704

    fun action(context: Context, name: String): String = "${context.packageName}.$name"

    // The switch widget's own table already decides what a tap means in every
    // run state, so the button borrows it rather than reasoning a second time.
    fun power(state: RunState): PendingIntent =
        state.toHomeWidgetPresentation().action.quickIntent.toPendingIntent

    fun hold(state: RunState): PendingIntent? = when (state) {
        RunState.STARTED -> QuickAction.PAUSE.quickIntent.toPendingIntent
        RunState.PAUSED -> QuickAction.RESUME.quickIntent.toPendingIntent
        else -> null
    }

    fun open(context: Context): PendingIntent = PendingIntent.getActivity(
        context,
        requestOpen,
        Components.mainActivity.intent.apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
        },
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

    fun examine(context: Context): PendingIntent =
        broadcast(context, requestExamine, EXAMINE, mutable = false)

    fun measure(context: Context): PendingIntent =
        broadcast(context, requestMeasure, MEASURE, mutable = false)

    // A collection template only carries the row's fill-in intent when the
    // system is allowed to mutate it, which S made opt-in.
    fun selectTemplate(context: Context): PendingIntent =
        broadcast(context, requestSelect, SELECT, mutable = true)

    fun selectFillIn(group: String, node: String): Intent = Intent().apply {
        putExtra(EXTRA_GROUP, group)
        putExtra(EXTRA_NODE, node)
    }

    private fun broadcast(
        context: Context,
        requestCode: Int,
        name: String,
        mutable: Boolean,
    ): PendingIntent {
        val intent = Intent(action(context, name)).apply {
            setPackage(context.packageName)
            setClass(context, WidgetActionReceiver::class.java)
        }
        val mutability = when {
            !mutable -> PendingIntent.FLAG_IMMUTABLE
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> PendingIntent.FLAG_MUTABLE
            else -> 0
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or mutability,
        )
    }
}
