package com.reclash.service.modules

import android.app.Service
import android.content.Intent
import android.hardware.display.DisplayManager
import android.os.Build
import android.os.PowerManager
import android.view.Display
import androidx.core.content.getSystemService
import com.reclash.common.receiveBroadcastFlow
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch

data class ScreenSnapshot(val screenOn: Boolean, val deviceIdle: Boolean)

// The whole battery strategy hinges on the core learning the screen is off.
// Two things make the bare broadcast unreliable: a dropped ACTION_SCREEN_OFF
// strands us in the screen-on state until the next on/off cycle, and
// PowerManager.isInteractive reads always-on-display and some lock screens as
// interactive. So screen-on is taken from the actual display state when it is
// available, and a watchdog re-samples while we believe the screen is on to
// catch a missed off. Screen-on wakeups are delivered reliably, so nothing
// ticks once we know it is off.
internal fun resolveScreenOn(mainDisplayOn: Boolean?, interactive: Boolean): Boolean =
    mainDisplayOn ?: interactive

internal class ScreenState(
    private val service: Service,
    private val scope: CoroutineScope,
) : ServiceModule {
    private val power: PowerManager?
        get() = service.getSystemService()

    private val displays: DisplayManager?
        get() = service.getSystemService()

    private val _state = MutableStateFlow(sample())
    val state: StateFlow<ScreenSnapshot> = _state.asStateFlow()

    override fun start() {
        scope.launch {
            service.receiveBroadcastFlow {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
                addAction(PowerManager.ACTION_DEVICE_IDLE_MODE_CHANGED)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    addAction(PowerManager.ACTION_DEVICE_LIGHT_IDLE_MODE_CHANGED)
                }
            }.collect { _state.value = sample() }
        }
        scope.launch {
            state.map { it.screenOn }.distinctUntilChanged().collectLatest { on ->
                if (!on) return@collectLatest
                while (true) {
                    delay(WATCHDOG_MS)
                    _state.value = sample()
                }
            }
        }
    }

    // The scope owns the coroutines, so cancelling it stops the sampling.
    override fun stop() = Unit

    private fun sample(): ScreenSnapshot {
        val interactive = power?.isInteractive ?: true
        val idle = power?.isDeviceIdleMode ?: false
        return ScreenSnapshot(resolveScreenOn(mainDisplayOn(), interactive), idle)
    }

    // The default display's own state is the screen-on truth: STATE_ON means the
    // user-facing panel is lit, while doze/off/suspend (always-on-display) and any
    // secondary or virtual display are not - a secondary display left STATE_ON was
    // stranding the whole tunnel in the screen-on state overnight. null when the
    // state cannot be read, so the caller falls back to isInteractive.
    private fun mainDisplayOn(): Boolean? {
        val display = displays?.getDisplay(Display.DEFAULT_DISPLAY) ?: return null
        return display.state == Display.STATE_ON
    }

    private companion object {
        const val WATCHDOG_MS = 45_000L
    }
}
