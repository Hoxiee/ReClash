package com.reclash.service.modules

object ConnectionResetPolicy {

    const val WINDOW_MS = 5_000L
}

enum class ResetAction { NOW, DEFER, COALESCE }

data class ResetPlan(val action: ResetAction, val delayMs: Long = 0)

// Leading edge, because a handover recovers only once the dead sockets are gone; the
// trailing coalesce then absorbs the callback burst a single handover fans out.
internal class ConnectionResetThrottle(
    private val windowMs: Long = ConnectionResetPolicy.WINDOW_MS,
) {
    private var lastAtMillis: Long? = null
    private var deferredUntilMillis: Long? = null

    @Synchronized
    fun request(nowMillis: Long): ResetPlan {
        if (deferredUntilMillis != null) return ResetPlan(ResetAction.COALESCE)
        val last = lastAtMillis
        if (last == null || nowMillis - last >= windowMs) {
            lastAtMillis = nowMillis
            return ResetPlan(ResetAction.NOW)
        }
        val until = last + windowMs
        deferredUntilMillis = until
        return ResetPlan(ResetAction.DEFER, until - nowMillis)
    }

    @Synchronized
    fun fire(nowMillis: Long): Boolean {
        if (deferredUntilMillis == null) return false
        deferredUntilMillis = null
        lastAtMillis = nowMillis
        return true
    }

    @Synchronized
    fun reset() {
        lastAtMillis = null
        deferredUntilMillis = null
    }
}
