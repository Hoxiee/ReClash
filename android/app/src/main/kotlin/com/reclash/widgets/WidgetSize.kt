package com.reclash.widgets

internal enum class WidgetWidth { TINY, SMALL, MEDIUM, WIDE }

internal enum class WidgetHeight { COMPACT, SHORT, TALL }

internal data class WidgetBox(val widthDp: Int, val heightDp: Int) {
    val width: WidgetWidth
        get() = when {
            widthDp < 110 -> WidgetWidth.TINY
            widthDp < 180 -> WidgetWidth.SMALL
            widthDp < 250 -> WidgetWidth.MEDIUM
            else -> WidgetWidth.WIDE
        }

    val height: WidgetHeight
        get() = when {
            heightDp < 58 -> WidgetHeight.COMPACT
            heightDp < 140 -> WidgetHeight.SHORT
            else -> WidgetHeight.TALL
        }

    val metricsFit: Boolean get() = heightDp >= 132

    val chipsFit: Boolean get() = heightDp >= 168

    val nodeRows: Int get() = ((heightDp - 50) / 34).coerceIn(1, 16)
}

// Launchers that predate the size API, and a few that simply lie, report 0;
// the declared minimum is the only honest fallback then.
internal fun widgetBoxOf(
    reportedWidthDp: Int,
    reportedHeightDp: Int,
    fallbackWidthDp: Int,
    fallbackHeightDp: Int,
): WidgetBox = WidgetBox(
    widthDp = if (reportedWidthDp > 0) reportedWidthDp else fallbackWidthDp,
    heightDp = if (reportedHeightDp > 0) reportedHeightDp else fallbackHeightDp,
)
