package com.reclash.common

import java.util.concurrent.atomic.AtomicBoolean

/**
 * Finishes `goAsync()` once even when work completion races the timeout. Releasing
 * the lease only ends Android's wait; the independently owned work keeps running.
 */
class BroadcastLease(private val release: () -> Unit) {
    private val released = AtomicBoolean(false)

    val isReleased: Boolean
        get() = released.get()

    fun release(onRelease: () -> Unit = {}): Boolean {
        if (!released.compareAndSet(false, true)) {
            return false
        }
        try {
            onRelease()
        } finally {
            release.invoke()
        }
        return true
    }
}
