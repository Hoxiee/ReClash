package com.reclash.common

import android.content.Context

/** Whether the last tunnel ended by a system revoke rather than by the app. */
object VpnTakeover {
    private const val PREFS = "vpn_takeover"
    private const val KEY_REVOKED_AT = "revokedAt"

    private val prefs
        get() = GlobalState.application.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    // Committed synchronously: the network callback that reads it fires as soon as the tunnel drops.
    fun recordRevoke() {
        prefs.edit().putLong(KEY_REVOKED_AT, System.currentTimeMillis()).commit()
    }

    fun clear() {
        if (prefs.contains(KEY_REVOKED_AT)) {
            prefs.edit().remove(KEY_REVOKED_AT).apply()
        }
    }

    val revoked: Boolean
        get() = prefs.contains(KEY_REVOKED_AT)
}
