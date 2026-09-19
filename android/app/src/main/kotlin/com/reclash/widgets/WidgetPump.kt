package com.reclash.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import com.reclash.HomeWidgetProvider
import com.reclash.RunState
import com.reclash.ServiceState
import com.reclash.common.GlobalState
import com.reclash.common.receiveBroadcastFlow
import com.reclash.service.ServiceConfig
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch

private const val tickMillis = 1_000L

// One clock for every widget: two tickers would disagree on the second.
internal object WidgetPump {
    private val revision = MutableStateFlow(0)
    private val installed = MutableStateFlow(false)
    private var job: Job? = null
    private var forced = true

    fun wake(context: Context) {
        val application = context.applicationContext
        installed.value = anyInstalled(application)
        forced = true
        if (!installed.value) {
            job?.cancel()
            job = null
            return
        }
        if (job?.isActive == true) {
            revision.value = revision.value + 1
            return
        }
        job = GlobalState.launch {
            // A cold process would otherwise draw STOPPED over a live tunnel.
            ServiceState.refresh()
            val updates = combine(
                ServiceState.runState,
                ServiceConfig.pauseState,
                ServiceConfig.smartRoutingStatus,
                ServiceConfig.doctorStatus,
                revision,
            ) { _ -> Unit }
            widgetUpdates(
                updates = updates,
                running = ServiceState.runState.map { it == RunState.STARTED },
                interactive = screenFlow(application),
                installed = installed,
                tickMillis = tickMillis,
            ).collect { render(application) }
        }
    }

    private fun render(context: Context) {
        if (!installed.value || !interactive(context)) return
        val manager = runCatching { AppWidgetManager.getInstance(context) }.getOrNull() ?: return
        val force = forced
        forced = false
        val snapshot = WidgetSnapshots.current(context)
        HomeWidgetProvider.updateAll(context, manager, snapshot)
        ControlWidgetProvider.updateAll(context, manager, snapshot)
        NodesWidgetProvider.updateAll(context, manager, snapshot, force)
    }

    private fun screenFlow(context: Context): Flow<Boolean> = context.receiveBroadcastFlow {
        addAction(Intent.ACTION_SCREEN_ON)
        addAction(Intent.ACTION_SCREEN_OFF)
        addAction(Intent.ACTION_USER_PRESENT)
    }.map { interactive(context) }
        .onStart { emit(interactive(context)) }
        .distinctUntilChanged()

    private fun interactive(context: Context): Boolean = runCatching {
        (context.getSystemService(Context.POWER_SERVICE) as? PowerManager)?.isInteractive != false
    }.getOrDefault(true)

    private fun anyInstalled(context: Context): Boolean {
        val manager = runCatching { AppWidgetManager.getInstance(context) }.getOrNull()
            ?: return false
        return listOf(
            HomeWidgetProvider::class.java,
            ControlWidgetProvider::class.java,
            NodesWidgetProvider::class.java,
        ).any { manager.widgetIds(context, it).isNotEmpty() }
    }
}
