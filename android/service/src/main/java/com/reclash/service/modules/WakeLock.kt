package com.reclash.service.modules

object WakeLockPolicy {

    // A pocketed phone reaches deep Doze only after tens of minutes of stillness, so an
    // untimed lock is effectively permanent; the tunnel only needs the CPU for the first
    // minutes after the screen goes off.
    const val GRACE_MS = 10 * 60 * 1000L
}

fun shouldHoldWakeLock(
    screenOn: Boolean,
    deviceIdle: Boolean,
    paused: Boolean,
): Boolean = !screenOn && !deviceIdle && !paused
