package com.reclash.service

internal class TunLifecycle {
    private val lock = Any()

    @Volatile
    private var stopping = false
    private var running = false

    fun canStart(): Boolean = !stopping

    fun start(
        start: () -> Unit,
        rollback: () -> Unit,
    ): Boolean = synchronized(lock) {
        if (stopping) {
            return@synchronized false
        }
        running = true
        try {
            start()
            true
        } catch (error: Throwable) {
            runCatching(rollback)
            running = false
            throw error
        }
    }

    fun pause(stop: () -> Unit): Boolean = synchronized(lock) {
        val wasRunning = running
        if (running) {
            stop()
            running = false
        }
        wasRunning
    }

    fun beginStop() {
        stopping = true
    }

    fun stop(stop: () -> Unit) = synchronized(lock) {
        if (running) {
            stop()
            running = false
        }
    }
}
