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

// Also the sticky-restart path: the system brings the service back without the app layer
// that configured it, and the app layer is what re-runs setup and hands the tun over.
internal fun Service.notifyStartRequested() {
    GlobalState.log("Service start requested: ${javaClass.simpleName}")
    BroadcastAction.VPN_START_REQUESTED.sendBroadcast()
}

internal fun Service.notifyVpnRevoked() {
    GlobalState.log("VPN permission revoked")
    BroadcastAction.VPN_REVOKED.sendBroadcast()
}
