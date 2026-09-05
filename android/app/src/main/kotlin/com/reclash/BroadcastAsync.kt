package com.reclash

import android.content.BroadcastReceiver
import android.os.Handler
import android.os.Looper
import com.reclash.common.BroadcastLease
import com.reclash.common.GlobalState
import kotlinx.coroutines.launch

private const val BROADCAST_TIMEOUT_MILLIS = 9_000L

private val mainHandler = Handler(Looper.getMainLooper())

// A receiver dies when onReceive returns, and the process dies if the broadcast is held too long.
internal fun BroadcastReceiver.handleAsync(action: String, work: suspend () -> Unit) {
    val pendingResult = goAsync()
    val lease = BroadcastLease { pendingResult.finish() }
    val timeout = Runnable {
        lease.release { GlobalState.log("Broadcast handling timed out: $action") }
    }
    mainHandler.postDelayed(timeout, BROADCAST_TIMEOUT_MILLIS)
    GlobalState.launch {
        try {
            work()
        } catch (error: Exception) {
            GlobalState.log("Unable to handle broadcast $action: $error")
        } finally {
            mainHandler.removeCallbacks(timeout)
            lease.release()
        }
    }
}
