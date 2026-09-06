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
        fun start(args: List<String>)

        fun stop()

        fun probe(port: Int): Boolean

        fun protectPath(): String?

        fun cacheFile(envKey: String): String?
    }

    private var configJob: Job? = null
    private var probeJob: Job? = null

    @Volatile private var current: ByeDpiTarget? = null
    @Volatile private var envKey = ""

    // The options flow and environment changes both land here from separate
    // coroutines; an interleaved stop would close the protect receiver under
    // a freshly started branch, leaving it to fail every dial.
    private val applyLock = Any()

    fun onEnvironmentChanged(key: String) {
        if (key == envKey) return
        envKey = key
        scope.launch { apply(targetOf(ServiceConfig.vpnOptions)) }
    }

    override fun start() {
        configJob = scope.launch {
            ServiceConfig.vpnOptionsFlow.collect { options -> apply(targetOf(options)) }
        }
    }

    override fun stop() {
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
            strategy = options.desyncStrategy,
            cacheTtl = if (options.desyncCacheTtl > 0) {
                options.desyncCacheTtl
            } else {
                BYEDPI_CACHE_TTL_SECONDS
            },
            cacheEnabled = options.desyncCacheEnabled,
            envKey = envKey,
        )
    }

    private fun apply(target: ByeDpiTarget?) {
        synchronized(applyLock) {
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
        val args = byeDpiArgs(
            port = target.port,
            strategy = target.strategy,
            cacheFile = engine.cacheFile(target.envKey),
            protectPath = engine.protectPath(),
            cacheTtlSeconds = target.cacheTtl,
            cacheEnabled = target.cacheEnabled,
        )
        current = target
        runCatching { engine.start(args) }
            .onFailure { error -> log("Desync start failed: $error") }
        probeJob = scope.launch { watch(target) }
    }

    // The thread outliving its listener is the failure Doze produces, so liveness is
    // "the listener still accepts a connection" and nothing weaker.
    private suspend fun watch(target: ByeDpiTarget) {
        var attempt = 0
        while (true) {
            delay(ByeDpiPolicy.PROBE_INTERVAL_MS)
            if (current != target) return
            if (engine.probe(target.port)) {
                attempt = 0
                continue
            }
            log("Desync listener is down, restarting")
            runCatching { engine.stop() }
            delay(ByeDpiPolicy.backoffMs(attempt++))
            if (current != target) return
            val args = byeDpiArgs(
                port = target.port,
                strategy = target.strategy,
                cacheFile = engine.cacheFile(target.envKey),
                protectPath = engine.protectPath(),
                cacheTtlSeconds = target.cacheTtl,
                cacheEnabled = target.cacheEnabled,
            )
            runCatching { engine.start(args) }
                .onFailure { error -> log("Desync restart failed: $error") }
        }
    }
}
