package com.reclash.common

/**
 * A replacement settles the superseded request; resolution clears the slot first,
 * so callbacks can start a new request without being resolved twice.
 *
 * The request and `onActivityResult` race across threads, so slot changes are
 * atomic. Callbacks run after unlocking to avoid holding this lock across resumed
 * coroutines and their lock order.
 */
class PendingCallback<T> {
    private val lock = Any()
    private var callback: ((T) -> Unit)? = null

    val isPending: Boolean
        get() = synchronized(lock) { callback != null }

    fun replace(next: (T) -> Unit, supersededValue: T) {
        val superseded = synchronized(lock) {
            val current = callback
            callback = next
            current
        }
        superseded?.invoke(supersededValue)
    }

    fun resolve(value: T) {
        val current = synchronized(lock) {
            val current = callback ?: return
            callback = null
            current
        }
        current(value)
    }

    fun cancel(target: (T) -> Unit) {
        synchronized(lock) {
            if (callback === target) {
                callback = null
            }
        }
    }
}
