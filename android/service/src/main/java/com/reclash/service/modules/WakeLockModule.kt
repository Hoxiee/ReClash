package com.reclash.service.modules

import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import androidx.core.content.getSystemService
import com.reclash.common.GlobalState
import com.reclash.common.receiveBroadcastFlow
import com.reclash.service.ServiceConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

internal class WakeLockModule(
    private val service: Service,
    private val scope: CoroutineScope,
) : ServiceModule {
    private val power: PowerManager?
        get() = service.getSystemService()

    private var lock: PowerManager.WakeLock? = null
    private var graceConsumed = false
    @Volatile
    private var stopped = false

    override fun start() {
        stopped = false
        scope.launch {
            service.receiveBroadcastFlow {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
                addAction(PowerManager.ACTION_DEVICE_IDLE_MODE_CHANGED)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    addAction(PowerManager.ACTION_DEVICE_LIGHT_IDLE_MODE_CHANGED)
                }
            }.collect { apply() }
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
        val screenOn = manager.isInteractive
        if (screenOn) graceConsumed = false
        when (
            wakeLockAction(
                screenOn = screenOn,
                deviceIdle = manager.isDeviceIdleMode,
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
