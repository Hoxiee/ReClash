package com.reclash

import com.reclash.models.SharedState
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay
import com.reclash.common.GlobalState
import com.reclash.service.ServiceConfig

object ServiceState {
    private val machine = ServiceStateMachine(AndroidServiceStateHost)

    init {
        GlobalState.launch {
            while (true) {
                delay(2_000)
                runCatching { machine.reconcileOnDemand(ServiceConfig.physicalNetworks.value) }
                    .onFailure { GlobalState.log("On-demand transition failed: $it") }
            }
        }
    }

    suspend fun setOnDemandPaused(paused: Boolean) = machine.setManualOnDemandPause(paused)

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
