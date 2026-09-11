package com.reclash.widgets

internal const val trafficHistorySize = 60

private const val trafficPeakFloor = 64L * 1024L

internal class WidgetTrafficHistory(private val capacity: Int = trafficHistorySize) {
    private val up = ArrayDeque<Long>()
    private val down = ArrayDeque<Long>()

    val size: Int get() = up.size

    fun push(upBytes: Long, downBytes: Long) {
        up.addLast(upBytes.coerceAtLeast(0L))
        down.addLast(downBytes.coerceAtLeast(0L))
        while (up.size > capacity) up.removeFirst()
        while (down.size > capacity) down.removeFirst()
    }

    fun clear() {
        up.clear()
        down.clear()
    }

    fun upSeries(): List<Long> = up.toList()

    fun downSeries(): List<Long> = down.toList()
}

// A floor keeps a few idle kilobytes from being drawn as a mountain range.
internal fun sparklinePeak(first: List<Long>, second: List<Long>): Long =
    maxOf(first.maxOrNull() ?: 0L, second.maxOrNull() ?: 0L, trafficPeakFloor)

internal fun sparklinePoints(
    values: List<Long>,
    width: Float,
    height: Float,
    peak: Long,
): FloatArray {
    if (values.isEmpty() || width <= 0f || height <= 0f) return FloatArray(0)
    val safePeak = peak.coerceAtLeast(1L).toFloat()
    val points = FloatArray(values.size * 2)
    val step = if (values.size > 1) width / (values.size - 1) else 0f
    values.forEachIndexed { index, value ->
        val ratio = (value.toFloat() / safePeak).coerceIn(0f, 1f)
        points[index * 2] = if (values.size > 1) step * index else width / 2f
        points[index * 2 + 1] = height - ratio * height
    }
    return points
}
