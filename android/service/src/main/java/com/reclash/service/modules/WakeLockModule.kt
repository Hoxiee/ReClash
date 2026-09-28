package com.reclash.service.modules

import android.app.Service
import android.os.PowerManager
import android.os.SystemClock
import androidx.core.content.getSystemService
import com.reclash.common.GlobalState
import com.reclash.service.ServiceConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

internal class WakeLockModule(
    private val service: Service,
    private val screenState: ScreenState,
    private val scope: CoroutineScope,
) : ServiceModule {
    private val power: PowerManager?
        get() = service.getSystemService()

    private var lock: PowerManager.WakeLock? = null
    private var graceConsumed = false
    private var screenOnAt: Long? = null
    @Volatile
    private var stopped = false

    override fun start() {
        stopped = false
        scope.launch {
            screenState.state.collect { apply() }
        }
        // A StateFlow replays its current value, which is also the initial evaluation.
        scope.launch {
            ServiceConfig.pauseState.collect { apply() }
        }
    }

    @Synchronized
    override fun stop() {
        stopped = true
        release()
    }

    @Synchronized
    private fun apply() {
        if (stopped) return
        val manager = power ?: return
        val snapshot = screenState.state.value
        val screenOn = snapshot.screenOn
        if (screenOn) {
            if (screenOnAt == null) screenOnAt = SystemClock.elapsedRealtime()
        } else {
            val onAt = screenOnAt
            if (onAt != null) {
                graceConsumed = graceConsumedAfterWake(
                    SystemClock.elapsedRealtime() - onAt,
                    WakeLockPolicy.BRIEF_WAKE_MS,
                )
                screenOnAt = null
            }
        }
        when (
            wakeLockAction(
                screenOn = screenOn,
                deviceIdle = snapshot.deviceIdle,
                paused = ServiceConfig.pauseState.value.paused,
                graceConsumed = graceConsumed,
            )
        ) {
            WakeLockAction.Acquire -> {
                graceConsumed = true
                acquire(manager)
            }
            WakeLockAction.Release -> release()
            WakeLockAction.Leave -> Unit
        }
    }

    private fun acquire(manager: PowerManager) {
        val current = lock ?: runCatching {
            manager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKE_LOCK_TAG)
        }.onFailure { error ->
            GlobalState.log("Wake lock unavailable: $error")
        }.getOrNull()?.also { lock = it } ?: return
        if (current.isHeld) return
        runCatching { current.acquire(WakeLockPolicy.GRACE_MS) }
            .onFailure { error -> GlobalState.log("Wake lock not acquired: $error") }
    }

    @Synchronized
    private fun release() {
        val current = lock ?: return
        if (!current.isHeld) return
        runCatching { current.release() }
            .onFailure { error -> GlobalState.log("Wake lock not released: $error") }
    }

    private companion object {
        const val WAKE_LOCK_TAG = "ReClash::tunnel"
    }
}
