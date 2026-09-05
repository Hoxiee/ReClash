package com.reclash

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.reclash.common.GlobalState

internal object BootActions {
    const val QUICK_BOOT = "android.intent.action.QUICKBOOT_POWERON"

    // Several OEM ROMs still send only their own spelling of the fast-boot broadcast.
    const val HTC_QUICK_BOOT = "com.htc.intent.action.QUICKBOOT_POWERON"

    fun isBoot(action: String): Boolean = when (action) {
        Intent.ACTION_BOOT_COMPLETED,
        Intent.ACTION_MY_PACKAGE_REPLACED,
        QUICK_BOOT,
        HTC_QUICK_BOOT,
        -> true

        else -> false
    }
}

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val action = intent?.action ?: return
        if (!BootActions.isBoot(action)) return
        if (!GlobalState.application.sharedState.autoRun) return
        handleAsync(action) {
            GlobalState.log("Auto start after $action")
            ServiceState.handleStartAction()
        }
    }
}
