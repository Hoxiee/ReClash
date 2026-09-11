package com.reclash

import android.appwidget.AppWidgetManager
import android.content.Context
import com.reclash.widgets.PumpWidgetProvider
import com.reclash.widgets.WidgetRenderer
import com.reclash.widgets.WidgetSnapshot
import com.reclash.widgets.orientationViews
import com.reclash.widgets.widgetIds

// Declared minimum from res/xml/home_widget_info, and the only honest guess at
// a placement's size on launchers that report none.
private const val switchWidthDp = 180
private const val switchHeightDp = 48

class HomeWidgetProvider : PumpWidgetProvider() {
    companion object {
        internal fun updateAll(
            context: Context,
            manager: AppWidgetManager,
            snapshot: WidgetSnapshot,
        ) {
            manager.widgetIds(context, HomeWidgetProvider::class.java).forEach { id ->
                val views = manager.orientationViews(id, switchWidthDp, switchHeightDp) { box ->
                    WidgetRenderer.switchWidget(context, snapshot, box)
                }
                manager.updateAppWidget(id, views)
            }
        }
    }
}
