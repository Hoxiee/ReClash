package com.reclash.service.modules

import com.reclash.common.GlobalState
import com.reclash.service.ServiceConfig
import com.reclash.service.models.VpnOptions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

internal data class ByeDpiTarget(
    val port: Int,
    val strategy: List<String>,
    val cacheTtl: Int,
    val cacheEnabled: Boolean,
    val envKey: String,
)

internal object ByeDpiPolicy {
    const val PROBE_INTERVAL_MS = 15_000L

    const val PROBE_MISSES = 2

    const val MAX_BACKOFF_MS = 30_000L

    fun backoffMs(attempt: Int): Long =
        (1_000L shl attempt.coerceAtMost(5)).coerceAtMost(MAX_BACKOFF_MS)
}

internal class ByeDpiModule(
    private val scope: CoroutineScope,
    private val engine: Engine,
    private val log: (String) -> Unit = GlobalState::log,
) : ServiceModule {

    interface Engine {
        fun start(args: List<String>): Boolean

        fun stop()

        fun probe(port: Int): Boolean

        fun protectPath(): String?

        fun cacheFile(envKey: String): String?
    }

    private var configJob: Job? = null
    private var probeJob: Job? = null

    @Volatile private var current: ByeDpiTarget? = null
    @Volatile private var envKey = ""
    private var startFailures = 0

    // Blocks a parked apply coroutine from resurrecting the branch after stop().
    @Volatile private var stopped = false

    // The options flow and environment changes both land here from separate
    // coroutines; an interleaved stop would close the protect receiver under
    // a freshly started branch, leaving it to fail every dial.
    private val applyLock = Any()

    fun onEnvironmentChanged(key: String) {
        if (stopped || key == envKey) return
        envKey = key
        scope.launch { apply(targetOf(ServiceConfig.vpnOptions)) }
    }

    override fun start() {
        stopped = false
        configJob = scope.launch {
            ServiceConfig.vpnOptionsFlow.collect { options -> apply(targetOf(options)) }
        }
    }

    override fun stop() {
        stopped = true
        configJob?.cancel()
        configJob = null
        synchronized(applyLock) {
            probeJob?.cancel()
            probeJob = null
            if (current != null) {
                current = null
                runCatching { engine.stop() }
            }
        }
    }

    private fun targetOf(options: VpnOptions?): ByeDpiTarget? {
        if (options?.desyncEnabled != true || options.desyncPort <= 0) return null
        return ByeDpiTarget(
            port = options.desyncPort,
            strategy = stripAppOwnedArgs(options.desyncStrategy) { flag ->
                log("Desync strategy flag '$flag' is app-owned, dropped")
            },
            cacheTtl = if (options.desyncCacheTtl > 0) {
                options.desyncCacheTtl
            } else {
                BYEDPI_CACHE_TTL_SECONDS
            },
            cacheEnabled = options.desyncCacheEnabled && !options.desyncTesting,
            envKey = envKey,
        )
    }

    private fun apply(target: ByeDpiTarget?) {
        synchronized(applyLock) {
            if (stopped) return
            if (target == current) return
            if (current != null) {
                probeJob?.cancel()
                probeJob = null
                current = null
                runCatching { engine.stop() }
                    .onFailure { error -> log("Desync stop failed: $error") }
            }
            if (target == null) return
            launchBranch(target)
        }
    }

    private fun launchBranch(target: ByeDpiTarget) {
        if (startEngine(target)) {
            probeJob = scope.launch { watch(target) }
        }
    }

    private fun startEngine(target: ByeDpiTarget): Boolean {
        val args = byeDpiArgs(
            port = target.port,
            strategy = target.strategy,
            cacheFile = engine.cacheFile(target.envKey),
            protectPath = engine.protectPath(),
            cacheTtlSeconds = target.cacheTtl,
            cacheEnabled = target.cacheEnabled,
        )
        val started = runCatching { engine.start(args) }
            .getOrElse { error ->
                log("Desync start failed: $error")
                false
            }
        if (started) {
            current = target
            startFailures = 0
        } else {
            current = null
            scheduleStartRetry(target)
        }
        return started
    }

    private fun scheduleStartRetry(target: ByeDpiTarget) {
        val delayMs = ByeDpiPolicy.backoffMs(startFailures++)
        scope.launch {
            delay(delayMs)
            synchronized(applyLock) {
                if (stopped || current != null) return@launch
                launchBranch(target)
            }
        }
    }

    private fun restart(target: ByeDpiTarget) {
        synchronized(applyLock) {
            if (current != target) return
            probeJob?.cancel()
            probeJob = null
            current = null
            runCatching { engine.stop() }
                .onFailure { error -> log("Desync stop failed: $error") }
            if (startEngine(target)) {
                probeJob = scope.launch { watch(target) }
            }
        }
    }

    // The thread outliving its listener is the failure Doze produces, so liveness is
    // "the listener still accepts a connection" and nothing weaker.
    private suspend fun watch(target: ByeDpiTarget) {
        var misses = 0
        var restarts = 0
        while (true) {
            delay(ByeDpiPolicy.PROBE_INTERVAL_MS)
            if (current != target) return
            if (engine.probe(target.port)) {
                misses = 0
                continue
            }
            if (++misses < ByeDpiPolicy.PROBE_MISSES) continue
            misses = 0
            log("Desync listener is down, restarting")
            restart(target)
            delay(ByeDpiPolicy.backoffMs(restarts++))
            if (current != target) return
        }
    }
}
