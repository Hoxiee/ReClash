package com.reclash.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Bundle
import com.reclash.R

// Declared minimums from res/xml, and the only honest guess at a placement's
// size on launchers that report none.
private const val controlWidthDp = 250
private const val controlHeightDp = 110
private const val nodesWidthDp = 180
private const val nodesHeightDp = 180

// A provider only reports that its placements changed; one pump decides what
// every widget draws, so two of them can never disagree about the same second.
abstract class PumpWidgetProvider : AppWidgetProvider() {
    override fun onEnabled(context: Context) = WidgetPump.wake(context)

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) = WidgetPump.wake(context)

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) = WidgetPump.wake(context)

    override fun onDeleted(context: Context, appWidgetIds: IntArray) = WidgetPump.wake(context)

    override fun onDisabled(context: Context) = WidgetPump.wake(context)
}

class ControlWidgetProvider : PumpWidgetProvider() {
    companion object {
        internal fun updateAll(
            context: Context,
            manager: AppWidgetManager,
            snapshot: WidgetSnapshot,
        ) {
            manager.widgetIds(context, ControlWidgetProvider::class.java).forEach { id ->
                val views = manager.orientationViews(id, controlWidthDp, controlHeightDp) { box ->
                    WidgetRenderer.control(context, snapshot, box)
                }
                manager.updateAppWidget(id, views)
            }
        }
    }
}

class NodesWidgetProvider : PumpWidgetProvider() {
    companion object {
        private var chrome = ""

        internal fun updateAll(
            context: Context,
            manager: AppWidgetManager,
            snapshot: WidgetSnapshot,
            force: Boolean,
        ) {
            val ids = manager.widgetIds(context, NodesWidgetProvider::class.java)
            if (ids.isEmpty()) {
                chrome = ""
                return
            }
            // Re-attaching the adapter restarts the list and drops the scroll
            // position, so the rows only move when their own facts do.
            val next = "${snapshot.group}|${snapshot.node}|${snapshot.tone}|" +
                "${snapshot.live}|${snapshot.routingEnabled}"
            if (!force && next == chrome) return
            chrome = next
            ids.forEach { id ->
                manager.updateAppWidget(id, WidgetRenderer.nodes(context, snapshot, id))
            }
            manager.notifyAppWidgetViewDataChanged(ids, R.id.widget_list)
        }

        fun notifyRows(context: Context) {
            val manager = runCatching { AppWidgetManager.getInstance(context) }.getOrNull()
                ?: return
            val ids = manager.widgetIds(context, NodesWidgetProvider::class.java)
            if (ids.isEmpty()) return
            manager.notifyAppWidgetViewDataChanged(ids, R.id.widget_list)
        }
    }
}

internal fun AppWidgetManager.nodesBox(appWidgetId: Int): WidgetBox =
    widgetBox(appWidgetId, nodesWidthDp, nodesHeightDp)
