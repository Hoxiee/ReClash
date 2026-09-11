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

internal fun parseActiveServer(raw: String, requestedGroup: String): String? {
    val value = gson.fromJson(raw, Any::class.java)
    return when (value) {
        is Map<*, *> -> {
            val group = value["group"] as? String
            val name = value["name"] as? String
            when {
                group == requestedGroup && !name.isNullOrBlank() -> name
                !name.isNullOrBlank() -> name
                else -> listOf("server", "proxy", "now")
                    .firstNotNullOfOrNull { key -> value[key] as? String }
            }
        }
        is String -> value
        else -> null
    }?.takeIf(String::isNotBlank)
}

fun Core.getActiveServerState(group: String): String? {
    return runCatching {
        parseActiveServer(getActiveServer(group), group)
    }.onFailure { error ->
        GlobalState.log("Unable to read active server: $error")
    }.getOrNull()
}

fun Core.getSpeedTrafficText(onlyStatisticsProxy: Boolean): String {
    return getTrafficState(onlyStatisticsProxy)?.speedText.orEmpty()
}
