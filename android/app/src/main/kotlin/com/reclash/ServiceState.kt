package com.reclash

import com.reclash.models.SharedState
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Job
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.conflate
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import com.reclash.common.GlobalState
import com.reclash.service.ServiceConfig

object ServiceState {
    private val machine = ServiceStateMachine(AndroidServiceStateHost)
    private val onDemandRechecks = MutableStateFlow(0L)

    init {
        GlobalState.launch { followOnDemandInputs() }
    }

    // A reconcile is never cancelled midway: it may be applying a pause to the service.
    private suspend fun followOnDemandInputs() = coroutineScope {
        var recheck: Job? = null
        combine(
            ServiceConfig.physicalNetworks,
            ServiceConfig.onDemandRevision,
            machine.onDemandSessions,
            onDemandRechecks,
        ) { networks, _, _, _ -> networks }.conflate().collect { networks ->
            recheck?.cancel()
            val after = runCatching { machine.reconcileOnDemand(networks) }
                .onFailure { GlobalState.log("On-demand transition failed: $it") }
                .getOrElse { ServiceStateMachine.ON_DEMAND_RETRY_MILLIS }
                ?: return@collect
            recheck = launch {
                delay(after)
                requestOnDemandRecheck()
            }
        }
    }

    private fun requestOnDemandRecheck() = onDemandRechecks.update { it + 1 }

    suspend fun setOnDemandPaused(paused: Boolean) {
        machine.setManualOnDemandPause(paused)
        requestOnDemandRecheck()
    }

    val runState = machine.runState

    val isRunRequested: Boolean
        get() = machine.isRunRequested

    fun attachFlutterEngine(engine: FlutterEngine) =
        AndroidServiceStateHost.attachFlutterEngine(engine)

    fun detachFlutterEngine(engine: FlutterEngine) =
        AndroidServiceStateHost.detachFlutterEngine(engine)

    suspend fun handleToggleAction() = machine.handleToggleAction()

    suspend fun handleStartAction() = machine.handleStartAction()

    suspend fun handleStopAction() = machine.handleStopAction()

    suspend fun handleVpnRevokeAction() = machine.handleVpnRevokeAction()

    suspend fun awaitRunTime(): Long = machine.awaitRunTime()

    fun requestStart(): Deferred<Boolean> = machine.requestStart()

    fun requestStop(): Deferred<Boolean> = machine.requestStop()

    fun syncSharedState(state: SharedState) = machine.syncSharedState(state)

    internal fun captureRequestToken(): RunRequest = machine.captureRequestToken()

    internal suspend fun handleServiceLost(token: RunRequest) = machine.handleServiceLost(token)
}
