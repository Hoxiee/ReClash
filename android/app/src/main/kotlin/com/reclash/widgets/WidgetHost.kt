package com.reclash.widgets

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews

internal fun AppWidgetManager.widgetIds(context: Context, provider: Class<*>): IntArray =
    runCatching { getAppWidgetIds(ComponentName(context, provider)) }.getOrDefault(IntArray(0))

internal fun AppWidgetManager.widgetBox(
    appWidgetId: Int,
    fallbackWidthDp: Int,
    fallbackHeightDp: Int,
): WidgetBox {
    val options = runCatching { getAppWidgetOptions(appWidgetId) }.getOrNull()
    return widgetBoxOf(
        reportedWidthDp = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) ?: 0,
        reportedHeightDp = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT) ?: 0,
        fallbackWidthDp = fallbackWidthDp,
        fallbackHeightDp = fallbackHeightDp,
    )
}

internal fun AppWidgetManager.orientationViews(
    appWidgetId: Int,
    fallbackWidthDp: Int,
    fallbackHeightDp: Int,
    build: (WidgetBox) -> RemoteViews,
): RemoteViews {
    val options = runCatching { getAppWidgetOptions(appWidgetId) }.getOrNull()
    val portrait = widgetBoxOf(
        reportedWidthDp = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) ?: 0,
        reportedHeightDp = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT) ?: 0,
        fallbackWidthDp = fallbackWidthDp,
        fallbackHeightDp = fallbackHeightDp,
    )
    val landscape = widgetBoxOf(
        reportedWidthDp = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH) ?: 0,
        reportedHeightDp = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT) ?: 0,
        fallbackWidthDp = fallbackWidthDp,
        fallbackHeightDp = fallbackHeightDp,
    )
    return if (landscape == portrait) {
        build(portrait)
    } else {
        RemoteViews(build(landscape), build(portrait))
    }
}
