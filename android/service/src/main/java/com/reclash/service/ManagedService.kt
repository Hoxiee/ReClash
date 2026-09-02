package com.reclash.service

import android.app.Service
import com.reclash.common.BroadcastAction
import com.reclash.common.GlobalState
import com.reclash.common.sendBroadcast

interface ManagedService {
    fun start()

    fun stop()

    // Only the TUN service can pause; the proxy-only service inherits no-ops.
    fun pause(manual: Boolean) {}

    fun resume(manual: Boolean) {}
}

internal fun Service.notifyVpnStartRequested() {
    GlobalState.log("VPN start requested")
    BroadcastAction.VPN_START_REQUESTED.sendBroadcast()
}

internal fun Service.notifyVpnRevoked() {
    GlobalState.log("VPN permission revoked")
    BroadcastAction.VPN_REVOKED.sendBroadcast()
}
