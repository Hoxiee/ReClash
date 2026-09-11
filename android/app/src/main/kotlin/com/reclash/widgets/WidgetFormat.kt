package com.reclash.widgets

import java.util.Locale

private const val byteStep = 1024.0

private val byteUnits = arrayOf("B", "KB", "MB", "GB", "TB")

internal fun formatBytes(bytes: Long): String {
    if (bytes <= 0L) return "0 B"
    var value = bytes.toDouble()
    var unit = 0
    while (value >= byteStep && unit < byteUnits.lastIndex) {
        value /= byteStep
        unit++
    }
    return if (unit == 0) {
        "${value.toLong()} ${byteUnits[unit]}"
    } else {
        String.format(Locale.US, "%.1f %s", value, byteUnits[unit])
    }
}

internal fun formatSpeed(bytesPerSecond: Long): String = "${formatBytes(bytesPerSecond)}/s"

internal fun formatUptime(millis: Long): String {
    val total = (millis / 1000L).coerceAtLeast(0L)
    val hours = total / 3600L
    val minutes = total % 3600L / 60L
    val seconds = total % 60L
    return if (hours > 0L) {
        String.format(Locale.US, "%d:%02d:%02d", hours, minutes, seconds)
    } else {
        String.format(Locale.US, "%02d:%02d", minutes, seconds)
    }
}

internal enum class DelayGrade { NONE, GOOD, MEDIUM, BAD }

// Mirrors getDelayColor, except that an unmeasured node stays neutral instead
// of borrowing the healthy colour.
internal fun delayGradeOf(delay: Int): DelayGrade = when {
    delay < 0 -> DelayGrade.BAD
    delay == 0 -> DelayGrade.NONE
    delay < 600 -> DelayGrade.GOOD
    else -> DelayGrade.MEDIUM
}

internal fun formatDelay(delay: Int): String = when {
    delay > 0 -> "$delay ms"
    delay < 0 -> "--"
    else -> ""
}

internal fun shorten(value: String, limit: Int): String =
    if (value.length <= limit) value else value.take(limit - 1).trimEnd() + "…"
