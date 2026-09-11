package com.reclash.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.os.SystemClock
import com.reclash.HomeWidgetProvider
import com.reclash.RunState
import com.reclash.ServiceState
import com.reclash.common.GlobalState
import com.reclash.common.receiveBroadcastFlow
import com.reclash.service.ServiceConfig
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.flow.shareIn
import kotlinx.coroutines.launch

private const val tickMillis = 1_000L

// One clock for every widget: two tickers would disagree on the second.
internal object WidgetPump {
    private val revision = MutableStateFlow(0)
    private val installed = MutableStateFlow(false)
    private val history = WidgetTrafficHistory()
    private var job: Job? = null
    private var forced = true
    private var lastPushAt = 0L

    // The one entry point: a caller need not know whether it already runs.
    fun wake(context: Context) {
        val application = context.applicationContext
        installed.value = anyInstalled(application)
        forced = true
        if (job?.isActive == true) {
            revision.value = revision.value + 1
            return
        }
        job = GlobalState.launch {
            // A cold process would otherwise draw STOPPED over a live tunnel.
            ServiceState.refresh()
            val awake = screenFlow(application)
                .shareIn(this, SharingStarted.Eagerly, replay = 1)
            combine(
                ServiceState.runState,
                ServiceConfig.pauseState,
                ServiceConfig.smartRoutingStatus,
                ServiceConfig.doctorStatus,
                revision,
                ticker(awake),
            ) { _ -> Unit }.collect { render(application) }
        }
    }

    private fun render(context: Context) {
        val manager = runCatching { AppWidgetManager.getInstance(context) }.getOrNull() ?: return
        val force = forced
        forced = false
        val snapshot = WidgetSnapshots.current(context)
        pushHistory(snapshot)
        HomeWidgetProvider.updateAll(context, manager, snapshot)
        ControlWidgetProvider.updateAll(context, manager, snapshot)
        NodesWidgetProvider.updateAll(context, manager, snapshot, force)
        TrafficWidgetProvider.updateAll(context, manager, snapshot, history)
    }

    // The x axis is wall clock, so a state-driven redraw must not shift it.
    private fun pushHistory(snapshot: WidgetSnapshot) {
        if (!snapshot.live) {
            history.clear()
            lastPushAt = 0L
            return
        }
        val now = SystemClock.elapsedRealtime()
        if (lastPushAt != 0L && now - lastPushAt < tickMillis - 100L) return
        lastPushAt = now
        history.push(snapshot.upSpeed, snapshot.downSpeed)
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    private fun ticker(awake: Flow<Boolean>): Flow<Unit> = combine(
        ServiceState.runState.map { it == RunState.STARTED }.distinctUntilChanged(),
        awake,
        installed,
    ) { running, interactive, present -> running && interactive && present }
        .distinctUntilChanged()
        .flatMapLatest { live ->
            if (live) {
                flow {
                    while (true) {
                        emit(Unit)
                        delay(tickMillis)
                    }
                }
            } else {
                flowOf(Unit)
            }
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
            TrafficWidgetProvider::class.java,
        ).any { manager.widgetIds(context, it).isNotEmpty() }
    }
}
