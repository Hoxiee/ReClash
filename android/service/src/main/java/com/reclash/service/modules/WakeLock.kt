package com.reclash.service.modules

object WakeLockPolicy {

    const val GRACE_MS = 2 * 60 * 1000L
}

fun shouldHoldWakeLock(
    screenOn: Boolean,
    deviceIdle: Boolean,
    paused: Boolean,
): Boolean = !screenOn && !deviceIdle && !paused
