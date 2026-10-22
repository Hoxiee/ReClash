package com.reclash.service.modules

import android.app.Service
import android.content.Intent
import android.os.BatteryManager
import android.os.PowerManager
import androidx.core.content.getSystemService
import com.google.gson.Gson
import com.reclash.common.receiveBroadcastFlow
import com.reclash.core.Core
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch

private data class PowerHints(
    val screen: Boolean,
    val doze: Boolean,
    val powerSave: Boolean,
    val batteryLow: Boolean,
)

private const val LOW_BATTERY_PERCENT = 20

private val gson = Gson()

// Sent on change only; the engine uses them just to schedule its own checks.
internal class RoutingHintsModule(
    private val service: Service,
    private val scope: CoroutineScope,
) : ServiceModule {
    private val power by lazy { service.getSystemService<PowerManager>() }
    private val battery by lazy { service.getSystemService<BatteryManager>() }

    override fun start() {
        scope.launch {
            service.receiveBroadcastFlow(exported = true) {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
                addAction(PowerManager.ACTION_DEVICE_IDLE_MODE_CHANGED)
                addAction(PowerManager.ACTION_POWER_SAVE_MODE_CHANGED)
                addAction(Intent.ACTION_BATTERY_LOW)
                addAction(Intent.ACTION_BATTERY_OKAY)
                addAction(Intent.ACTION_POWER_CONNECTED)
                addAction(Intent.ACTION_POWER_DISCONNECTED)
            }.map { snapshot() }
                .onStart { emit(snapshot()) }
                .distinctUntilChanged()
                .collect { hints -> Core.setRcxHints(gson.toJson(hints)) }
        }
    }

    private fun snapshot(): PowerHints {
        val charging = battery?.isCharging ?: false
        val level = battery?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: 100
        return PowerHints(
            screen = power?.isInteractive ?: true,
            doze = power?.isDeviceIdleMode ?: false,
            powerSave = power?.isPowerSaveMode ?: false,
            batteryLow = !charging && level in 0 until LOW_BATTERY_PERCENT,
        )
    }

    override fun stop() {}
}

private data class NetworkHint(val transport: String, val id: String, val portal: Boolean)

private data class NetworkHints(val network: NetworkHint, val metered: Boolean)

private var lastNetworkHints: NetworkHints? = null

// Without location permission there is no SSID; the DNS servers stand in as
// the network's identity, which the Core hashes before keeping it.
@Synchronized
internal fun sendNetworkHint(transport: String, id: String, metered: Boolean, portal: Boolean) {
    val hints = NetworkHints(NetworkHint(transport, id, portal), metered)
    if (hints == lastNetworkHints) return
    lastNetworkHints = hints
    Core.setRcxHints(gson.toJson(hints))
}
