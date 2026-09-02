package com.reclash.common

import java.util.concurrent.atomic.AtomicReference

/**
 * Every request mints a fresh [Token]. Work that was started for an older token is obsolete once a
 * newer request arrives, so callers check [isCurrent] before applying a result and roll back with
 * [resetToStopped], which only wins while the token is still the latest one.
 */
class RunIntentArbiter(initialRunning: Boolean = false) {
    class Token internal constructor(
        val running: Boolean,
        val paused: Boolean = false,
    )

    private val latest = AtomicReference(Token(initialRunning))

    val isRunningRequested: Boolean
        get() = latest.get().running

    val isPausedRequested: Boolean
        get() = latest.get().paused

    fun current(): Token = latest.get()

    fun request(running: Boolean, paused: Boolean = false): Token =
        Token(running, paused).also(latest::set)

    fun isCurrent(token: Token): Boolean = latest.get() === token

    fun resetToStopped(token: Token): Boolean =
        latest.compareAndSet(token, Token(running = false))
}
