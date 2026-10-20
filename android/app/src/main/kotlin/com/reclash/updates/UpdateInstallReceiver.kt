package com.reclash.updates

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.reclash.common.BroadcastLease
import com.reclash.common.GlobalState
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class UpdateInstallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pending = goAsync()
        val lease = BroadcastLease { pending.finish() }
        val timeout = Runnable {
            lease.release { GlobalState.log("Update installation callback timed out") }
        }
        mainHandler.postDelayed(timeout, CALLBACK_TIMEOUT_MILLIS)
        GlobalState.launch(Dispatchers.IO) {
            try {
                UpdateInstaller.receive(context.applicationContext, intent)
            } catch (error: Exception) {
                GlobalState.log("Update installation callback failed: $error")
            } finally {
                mainHandler.removeCallbacks(timeout)
                lease.release()
            }
        }
    }

    companion object {
        private const val CALLBACK_TIMEOUT_MILLIS = 9_000L
        private val mainHandler = Handler(Looper.getMainLooper())
    }
}
