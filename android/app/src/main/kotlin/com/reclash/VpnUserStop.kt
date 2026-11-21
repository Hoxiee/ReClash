package com.reclash

/** Whether this process stopped the tunnel itself, so an always-on restart stays down. */
internal object VpnUserStop {
    @Volatile
    var stopped = false
        private set

    fun record() {
        stopped = true
    }

    fun clear() {
        stopped = false
    }
}
