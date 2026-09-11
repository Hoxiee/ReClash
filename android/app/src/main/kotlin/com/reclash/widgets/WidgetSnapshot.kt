package com.reclash.widgets

import com.reclash.RunState

internal enum class WidgetTone { IDLE, PENDING, ACTIVE, DEGRADED, BROKEN, PAUSED }

internal data class WidgetSnapshot(
    val runState: RunState = RunState.STOPPED,
    val profile: String = "",
    val group: String = "",
    val node: String = "",
    val delay: Int = 0,
    val terrain: String = "",
    val routingEnabled: Boolean = false,
    val searching: Boolean = false,
    val doctorState: String = "",
    val doctorHealth: String = "",
    val upSpeed: Long = 0L,
    val downSpeed: Long = 0L,
    val sessionUp: Long = 0L,
    val sessionDown: Long = 0L,
    val startedAtMillis: Long = 0L,
)

internal val WidgetSnapshot.live: Boolean
    get() = runState == RunState.STARTED || runState == RunState.PAUSED

// The tone drives every coloured surface across the four widgets, so a
// transition never shows a stale verdict: a pending lifecycle outranks health.
internal val WidgetSnapshot.tone: WidgetTone
    get() = when {
        runState == RunState.STOPPED -> WidgetTone.IDLE
        runState == RunState.STARTING || runState == RunState.STOPPING -> WidgetTone.PENDING
        runState == RunState.PAUSED -> WidgetTone.PAUSED
        doctorState == "examining" || searching -> WidgetTone.PENDING
        doctorHealth == "broken" -> WidgetTone.BROKEN
        doctorHealth == "degraded" -> WidgetTone.DEGRADED
        else -> WidgetTone.ACTIVE
    }

internal val WidgetSnapshot.uptimeMillis: Long
    get() = if (live && startedAtMillis > 0L) {
        (System.currentTimeMillis() - startedAtMillis).coerceAtLeast(0L)
    } else {
        0L
    }
