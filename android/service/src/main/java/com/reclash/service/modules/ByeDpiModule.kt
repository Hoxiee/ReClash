package com.reclash.service.modules

import com.reclash.common.GlobalState
import com.reclash.service.ServiceConfig
import com.reclash.service.models.VpnOptions
import java.util.concurrent.atomic.AtomicLong
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

private val byeDpiStatusGeneration = AtomicLong()

internal enum class ByeDpiState(val wireName: String) {
    STOPPED("stopped"),
    STARTING("starting"),
    HEALTHY("healthy"),
    RECOVERING("recovering"),
    FAILED("failed"),
}

internal data class ByeDpiStatusProjection(
    val state: ByeDpiState,
    val generation: Long,
    val at: Long,
) {
    fun toJson(): String =
        """{"state":"${state.wireName}","generation":$generation,"at":$at}"""
}

internal class ByeDpiModule(
    private val scope: CoroutineScope,
    private val engine: Engine,
    private val status: (ByeDpiStatusProjection) -> Unit = {},
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
    private var retryJob: Job? = null

    @Volatile private var current: ByeDpiTarget? = null
    @Volatile private var requested: ByeDpiTarget? = null
    @Volatile private var envKey = ""
    private var startFailures = 0
    private var lastStatus: ByeDpiState? = null

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
        publishStatus(ByeDpiState.STOPPED)
        configJob = scope.launch {
            ServiceConfig.vpnOptionsFlow.collect { options -> apply(targetOf(options)) }
        }
    }

    override fun stop() {
        stopped = true
        configJob?.cancel()
        configJob = null
        synchronized(applyLock) {
            retryJob?.cancel()
            retryJob = null
            requested = null
            probeJob?.cancel()
            probeJob = null
            if (current != null) {
                current = null
                runCatching { engine.stop() }
            }
            publishStatus(ByeDpiState.STOPPED)
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
            if (target == requested) return
            requested = target
            retryJob?.cancel()
            retryJob = null
            if (current != null) {
                probeJob?.cancel()
                probeJob = null
                current = null
                runCatching { engine.stop() }
                    .onFailure { error -> log("Desync stop failed: $error") }
            }
            if (target == null) {
                publishStatus(ByeDpiState.STOPPED)
                return
            }
            publishStatus(ByeDpiState.STARTING)
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
            retryJob = null
            startFailures = 0
            publishStatus(ByeDpiState.HEALTHY)
        } else {
            current = null
            publishStatus(ByeDpiState.FAILED)
            scheduleStartRetry(target)
        }
        return started
    }

    private fun scheduleStartRetry(target: ByeDpiTarget) {
        val delayMs = ByeDpiPolicy.backoffMs(startFailures++)
        retryJob = scope.launch {
            delay(delayMs)
            synchronized(applyLock) {
                if (stopped || requested != target || current != null) return@launch
                retryJob = null
                publishStatus(ByeDpiState.STARTING)
                launchBranch(target)
            }
        }
    }

    private fun restart(target: ByeDpiTarget) {
        synchronized(applyLock) {
            if (current != target) return
            publishStatus(ByeDpiState.RECOVERING)
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

    private fun publishStatus(state: ByeDpiState) {
        if (lastStatus == state) return
        lastStatus = state
        val projection = ByeDpiStatusProjection(
            state = state,
            generation = byeDpiStatusGeneration.incrementAndGet(),
            at = System.currentTimeMillis(),
        )
        runCatching { status(projection) }
            .onFailure { error -> log("Desync status publish failed: $error") }
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
