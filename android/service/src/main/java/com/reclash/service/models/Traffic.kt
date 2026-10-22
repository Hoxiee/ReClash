package com.reclash.service.models

import com.reclash.common.GlobalState
import com.reclash.core.Core
import com.google.gson.Gson

private val gson = Gson()

data class Traffic(
    val up: Long,
    val down: Long,
) {
    val isIdle: Boolean
        get() = up == 0L && down == 0L
}

private val Long.formatBytes: String
    get() {
        val units = arrayOf("B", "KB", "MB", "GB", "TB")
        var value = toDouble()
        var unit = 0
        while (value >= 1024 && unit < units.lastIndex) {
            value /= 1024
            unit++
        }
        return if (unit == 0) {
            "${value.toLong()}${units[unit]}"
        } else {
            "%.1f${units[unit]}".format(value)
        }
    }

val Traffic.speedText: String
    get() = "${up.formatBytes}/s↑  ${down.formatBytes}/s↓"

val Traffic.totalText: String
    get() = "${up.formatBytes}↑  ${down.formatBytes}↓"

fun Core.getTrafficState(onlyStatisticsProxy: Boolean): Traffic? {
    return runCatching {
        gson.fromJson(getTraffic(onlyStatisticsProxy), Traffic::class.java)
    }.onFailure { error ->
        GlobalState.log("Unable to read traffic: $error")
    }.getOrNull()
}

fun Core.getTotalTrafficState(onlyStatisticsProxy: Boolean): Traffic? {
    return runCatching {
        gson.fromJson(getTotalTraffic(onlyStatisticsProxy), Traffic::class.java)
    }.onFailure { error ->
        GlobalState.log("Unable to read total traffic: $error")
    }.getOrNull()
}

fun Core.getSpeedTrafficText(onlyStatisticsProxy: Boolean): String {
    return getTrafficState(onlyStatisticsProxy)?.speedText.orEmpty()
}
