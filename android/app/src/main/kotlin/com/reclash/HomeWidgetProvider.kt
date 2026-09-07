package com.reclash

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews
import com.reclash.common.GlobalState
import com.reclash.common.quickIntent
import com.reclash.common.toPendingIntent
import kotlinx.coroutines.launch

class HomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        GlobalState.launch {
            ServiceState.refresh()
            update(context, appWidgetManager, appWidgetIds, ServiceState.runState.value)
        }
    }

    companion object {
        fun updateAll(context: Context, runState: RunState) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, HomeWidgetProvider::class.java)
            update(context, manager, manager.getAppWidgetIds(component), runState)
        }

        private fun update(
            context: Context,
            manager: AppWidgetManager,
            widgetIds: IntArray,
            runState: RunState,
        ) {
            if (widgetIds.isEmpty()) return
            val presentation = runState.toHomeWidgetPresentation()
            val views = RemoteViews(context.packageName, R.layout.home_widget).apply {
                setTextViewText(R.id.widget_status, context.getText(presentation.statusRes))
                setTextViewText(
                    R.id.widget_action,
                    context.getText(presentation.actionLabelRes),
                )
                setOnClickPendingIntent(
                    R.id.widget_root,
                    presentation.action.quickIntent.toPendingIntent,
                )
            }
            manager.updateAppWidget(widgetIds, views)
        }
    }
}
