package com.reclash.byedpi

/// Loaded on first use, never in an initializer: while the feature is off the branch leaves no trace.
object ByeDpiNative {
    private var loaded = false

    fun runUntilStopped(args: List<String>): Int {
        ensureLoaded()
        return nativeStart(args.toTypedArray())
    }

    fun stop() {
        if (loaded) nativeStop()
    }

    fun setDns(ip: String?) {
        ensureLoaded()
        nativeSetDns(ip)
    }

    @Synchronized
    private fun ensureLoaded() {
        if (loaded) return
        System.loadLibrary("byedpi")
        loaded = true
    }

    private external fun nativeStart(args: Array<String>): Int

    private external fun nativeStop()

    private external fun nativeSetDns(ip: String?)
}
