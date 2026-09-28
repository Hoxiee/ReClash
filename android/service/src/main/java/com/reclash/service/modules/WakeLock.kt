package com.reclash.service.modules

object WakeLockPolicy {

    const val GRACE_MS = 2 * 60 * 1000L

    // A wake shorter than this is a glance — a notification peek, a lock-screen
    // check — not a session. Re-arming the screen-off grace after one hands out
    // a fresh 2-minute wake lock for every glance, so a brief wake leaves the
    // grace spent and the ensuing screen-off keeps the CPU free to suspend.
    const val BRIEF_WAKE_MS = 5 * 1000L
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

// A just-ended screen-on episode re-arms the grace only when it was a real
// session; a glance leaves the grace consumed so no fresh wake lock is taken.
fun graceConsumedAfterWake(onEpisodeMs: Long, briefMs: Long): Boolean =
    onEpisodeMs < briefMs
