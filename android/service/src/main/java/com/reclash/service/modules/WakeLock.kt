package com.reclash.service.modules

object WakeLockPolicy {

    const val GRACE_MS = 2 * 60 * 1000L
}

enum class WakeLockAction { Acquire, Release, Leave }

// The screen-off grace is granted once per screen-off episode: a short settle
// window for an in-flight transfer, then the CPU is free to suspend. Renewing it
// on every Doze-churn broadcast is what pinned the SoC awake all night.
fun wakeLockAction(
    screenOn: Boolean,
    deviceIdle: Boolean,
    paused: Boolean,
    graceConsumed: Boolean,
): WakeLockAction = when {
    screenOn || deviceIdle || paused -> WakeLockAction.Release
    graceConsumed -> WakeLockAction.Leave
    else -> WakeLockAction.Acquire
}
