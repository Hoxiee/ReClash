package com.reclash.service.modules

import android.os.SystemClock
import com.reclash.common.GlobalState
import com.reclash.service.PauseState
import com.reclash.service.ServiceConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

internal class SmartPauseModule(
    private val scope: CoroutineScope,
    private val actions: Actions,
    private val uptimeMillis: () -> Long = SystemClock::uptimeMillis,
    private val log: (String) -> Unit = GlobalState::log,
) : ServiceModule {

    interface Actions {
        fun pause()

        fun resume()
    }

    private var eventJob: Job? = null
    private var events = Channel<String>(Channel.CONFLATED)

    @Volatile private var lastIpv4: List<String> = emptyList()
    @Volatile private var lastSsids: List<String> = emptyList()
    @Volatile private var manualAnchor: List<String>? = null
    @Volatile private var transitionAttempts = 0

    fun onPhysicalNetworksChanged(ips: List<String>, ssids: List<String>) {
        lastIpv4 = ips
        lastSsids = ssids
        events.trySend("network")
    }

    override fun start() {
        eventJob = scope.launch {
            for (reason in events) {
                delay(SmartPausePolicy.DECISION_DEBOUNCE_MS)
                // A fresh event re-arms the retry budget; the retry event itself must not.
                if (reason != TRANSITION_RETRY) transitionAttempts = 0
                runCatching { evaluate(reason) }
                    .onFailure { error -> log("SmartPause evaluation failed: $error") }
            }
        }
        scope.launch {
            ServiceConfig.pauseState.collect(::onPauseStateChanged)
        }
        scope.launch {
            ServiceConfig.vpnOptionsFlow.collect {
                events.trySend(EVENT_CONFIG)
            }
        }
    }

    override fun stop() {
        eventJob?.cancel()
        eventJob = null
    }

    private fun onPauseStateChanged(state: PauseState) {
        if (state.paused && state.manual && manualAnchor == null) {
            manualAnchor = currentAnchor()
        }
        if (!state.paused) {
            manualAnchor = null
        }
    }

    private suspend fun evaluate(reason: String) {
        val pauseState = ServiceConfig.pauseState.value
        if (pauseState.paused && pauseState.manual) {
            evaluateManualAnchor()
            return
        }
        val config = currentConfig()
        val session = SmartPauseSessionState(
            running = !pauseState.paused,
            paused = pauseState.paused,
            sessionAgeMs = (uptimeMillis() - ServiceConfig.sessionStartedAt).coerceAtLeast(0L),
        )
        val networkKnown = lastIpv4.isNotEmpty() || lastSsids.isNotEmpty()
        val trusted = isTrusted(config)
        when (evaluateSmartPause(config, session, networkKnown, trusted)) {
            SmartPauseDecision.PAUSE -> {
                val guardLeft = SmartPausePolicy.STARTUP_GUARD_MS - session.sessionAgeMs
                if (guardLeft > 0) {
                    scope.launch {
                        delay(guardLeft)
                        events.trySend(EVENT_GUARD)
                    }
                    return
                }
                log("SmartPause ($reason): trusted network, pausing")
                runTransition("pause") { applyPause() }
            }

            SmartPauseDecision.RESUME -> {
                log("SmartPause ($reason): left trusted network, resuming")
                runTransition("resume") { applyResume() }
            }

            SmartPauseDecision.NONE -> Unit
        }
    }

    // A manual pause holds until its anchor network is left: trusted
    // destination keeps the pause as a policy one, anything else resumes.
    private suspend fun evaluateManualAnchor() {
        val anchor = manualAnchor ?: return
        val current = currentAnchor()
        if (current.isEmpty() || current == anchor) return
        if (anchor.isEmpty()) {
            manualAnchor = current
            return
        }
        val config = currentConfig()
        if (config.enabled && config.networks.isNotEmpty() && isTrusted(config)) {
            manualAnchor = null
            ServiceConfig.updatePauseState(PauseState(paused = true, manual = false))
            return
        }
        log("SmartPause: manual pause anchor changed, resuming")
        runTransition("resume") { applyResume() }
    }

    private fun runTransition(what: String, action: () -> Boolean): Boolean {
        if (action()) {
            transitionAttempts = 0
            log("SmartPause: $what applied")
            return true
        }
        val attempt = transitionAttempts++
        val backoff = transitionRetryPlan(attempt)
        if (backoff == null) {
            log("SmartPause: $what gave up after ${SmartPausePolicy.TRANSITION_RETRIES} attempts")
            return false
        }
        log("SmartPause: $what rejected, re-evaluating in ${backoff}ms")
        scope.launch {
            delay(backoff)
            events.trySend(TRANSITION_RETRY)
        }
        return false
    }

    private fun applyPause(): Boolean = runCatching {
        actions.pause()
        ServiceConfig.pauseState.value.paused
    }.getOrDefault(false)

    private fun applyResume(): Boolean = runCatching {
        actions.resume()
        !ServiceConfig.pauseState.value.paused
    }.getOrDefault(false)

    private fun isTrusted(config: SmartPauseConfig): Boolean =
        TrustedNetworkMatcher.matchesAny(lastIpv4, config.networks) ||
            TrustedNetworkMatcher.matchesSsid(lastSsids, config.networks)

    private fun currentAnchor(): List<String> =
        if (lastSsids.isNotEmpty()) {
            lastSsids
        } else {
            lastIpv4.map { "${it.substringBeforeLast('.')}.0/24" }.sorted()
        }

    private fun currentConfig(): SmartPauseConfig {
        val options = ServiceConfig.vpnOptions
        return SmartPauseConfig(
            enabled = options?.smartPauseEnabled == true,
            networks = options?.smartPauseNetworks.orEmpty(),
        )
    }

    private companion object {
        const val EVENT_CONFIG = "config"
        const val EVENT_GUARD = "guard"
        const val TRANSITION_RETRY = "transition_retry"
    }
}
