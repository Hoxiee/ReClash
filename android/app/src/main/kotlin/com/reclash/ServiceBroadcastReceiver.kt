package com.reclash

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.reclash.common.BroadcastAction
import com.reclash.common.GlobalState
import com.reclash.common.action

class ServiceBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val action = intent?.action ?: return
        handleAsync(action) { handleAction(action) }
    }

    private suspend fun handleAction(action: String) {
        when (action) {
            BroadcastAction.VPN_START_REQUESTED.action -> {
                GlobalState.log("System requested VPN service start")
                ServiceState.handleStartAction()
            }

            BroadcastAction.VPN_REVOKED.action -> {
                GlobalState.log("VPN permission revoked")
                ServiceState.handleVpnRevokeAction()
            }
        }
    }
}
