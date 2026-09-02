package com.reclash

import com.reclash.common.RunIntentArbiter
import com.reclash.models.SharedState
import com.reclash.service.models.NotificationParams
import com.reclash.service.models.VpnOptions
import com.google.gson.Gson
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlin.coroutines.resume

enum class RunState {
    STARTED,
    STARTING,
    STOPPING,
    STOPPED,
    PAUSED,
}

internal typealias RunRequest = RunIntentArbiter.Token

internal const val MISSING_CONFIG_MESSAGE = "No configuration found."
internal const val INVALID_CONFIG_MESSAGE = "Invalid configuration."
internal const val VPN_PERMISSION_MESSAGE = "VPN permission required."
internal const val START_FAILED_MESSAGE = "Failed to start service."

/**
 * Callers request a transition; the newest request always wins. Every step that outlives its own
 * suspension point re-checks [isCurrent] before it publishes anything, so a start that was overtaken
 * by a stop cannot report itself as started.
 */
internal class ServiceStateMachine(private val host: ServiceStateHost) {
    private val transitionLock = Mutex()
    private val startPreparationLock = Mutex()
    private val mutableRunState = MutableStateFlow(RunState.STOPPED)
    private val arbiter = RunIntentArbiter()

    @Volatile
    private var sharedState = SharedState()

    @Volatile
    private var pendingVpnPreparation: (() -> Unit)? = null

    val runState = mutableRunState.asStateFlow()

    private val runTimeMillis: Long
        get() = host.runTimeMillis

    init {
        // The service pauses itself natively (smart pause policy), so the machine
        // projects the service's own flag instead of owning it.
        host.scope.launch {
            host.pauseState.collect { state -> syncPaused(state.paused) }
        }
    }

    suspend fun handleToggleAction() {
        when {
            runState.value == RunState.PAUSED -> handleResumeAction()
            isRunningRequested() -> handleStopAction()
            else -> handleStartAction()
        }
    }

    suspend fun refresh(): Long = transitionLock.withLock {
        val current = runTimeMillis
        mutableRunState.value = when {
            current == 0L -> RunState.STOPPED
            host.pauseState.value.paused -> RunState.PAUSED
            else -> RunState.STARTED
        }
        current
    }

    fun captureRequestToken(): RunRequest = arbiter.current()

    /**
     * Settles the state after the bound service was lost. [token] is the request that was current
     * when the loss was observed, so a start that raced ahead of this callback keeps its intent.
     */
    suspend fun handleServiceLost(token: RunRequest) = transitionLock.withLock {
        if (runTimeMillis != 0L) {
            return@withLock
        }
        if (!arbiter.resetToStopped(token)) {
            return@withLock
        }
        mutableRunState.value = RunState.STOPPED
    }

    suspend fun handleStartAction() {
        if (runState.value == RunState.PAUSED) {
            handleResumeAction()
            return
        }
        if (isRunningRequested()) {
            return
        }
        val tile = host.tile()
        if (tile != null) {
            tile.handleStart()
            return
        }
        loadPreferencesAndStart()
    }

    suspend fun handleStopAction() {
        if (!isRunningRequested()) {
            return
        }
        val tile = host.tile()
        if (tile != null) {
            tile.handleStop()
            return
        }
        host.showToast(sharedState.stopTip)
        requestStop().await()
    }

    suspend fun handlePauseAction() {
        if (runState.value != RunState.STARTED) {
            return
        }
        val tile = host.tile()
        if (tile != null) {
            tile.handlePause()
            return
        }
        host.showToast(sharedState.pauseTip)
        requestPause().await()
    }

    suspend fun handleResumeAction() {
        if (runState.value != RunState.PAUSED) {
            return
        }
        val tile = host.tile()
        if (tile != null) {
            tile.handleResume()
            return
        }
        requestResume().await()
    }

    suspend fun handleVpnRevokeAction() {
        if (!host.isVpnServiceActive()) {
            return
        }
        handleStopAction()
    }

    fun requestStart(): Deferred<Boolean> {
        val request = createRequest(running = true)
        val result = CompletableDeferred<Boolean>()
        val launchRequest: (Boolean) -> Unit = { shouldStart ->
            if (!shouldStart) {
                fail(request)
                result.complete(false)
            } else {
                host.scope.launch {
                    result.complete(
                        runCatching { start(request) }
                            .onFailure { error ->
                                host.log("Unable to process service start request: $error")
                                fail(request)
                                reconcileStopped()
                            }
                            .getOrDefault(false),
                    )
                }
            }
        }
        val app = host.app()
        if (app != null) {
            app.requestNotificationPermission(launchRequest)
        } else {
            launchRequest(true)
        }
        return result
    }

    fun requestStop(): Deferred<Boolean> {
        val request = createRequest(running = false)
        val result = CompletableDeferred<Boolean>()
        host.scope.launch {
            result.complete(
                runCatching { stop(request) }
                    .onFailure { error ->
                        host.log("Unable to process service stop request: $error")
                    }
                    .getOrDefault(false),
            )
        }
        return result
    }

    fun requestPause(): Deferred<Boolean> {
        val request = createRequest(running = true, paused = true)
        val result = CompletableDeferred<Boolean>()
        host.scope.launch {
            result.complete(
                runCatching { pause(request) }
                    .onFailure { error ->
                        host.log("Unable to process service pause request: $error")
                    }
                    .getOrDefault(false),
            )
        }
        return result
    }

    fun requestResume(): Deferred<Boolean> {
        val request = createRequest(running = true, paused = false)
        val result = CompletableDeferred<Boolean>()
        host.scope.launch {
            result.complete(
                runCatching { resume(request) }
                    .onFailure { error ->
                        host.log("Unable to process service resume request: $error")
                    }
                    .getOrDefault(false),
            )
        }
        return result
    }

    fun syncSharedState(state: SharedState) {
        sharedState = state
        applySharedState()
    }

    private suspend fun loadPreferencesAndStart() {
        sharedState = host.loadSharedState()
        if (sharedState.setupParams == null || sharedState.vpnOptions == null) {
            host.showToast(MISSING_CONFIG_MESSAGE)
            return
        }
        if (setupCore()) {
            if (!requestStart().await()) {
                host.showToast(START_FAILED_MESSAGE)
            }
        }
    }

    private fun applySharedState() {
        host.setCrashlytics(sharedState.crashlytics)
        host.updateNotificationParams(notificationParams(sharedState))
        sharedState.vpnOptions?.let(host::updateVpnOptions)
    }

    private suspend fun setupCore(): Boolean {
        applySharedState()
        host.showToast(sharedState.startTip)
        return host.quickSetup(
            initParams(host.homeDirPath, host.sdkInt),
            Gson().toJson(sharedState.setupParams),
        ).fold(
            onSuccess = { message ->
                if (message.isEmpty()) {
                    true
                } else {
                    host.log("Unable to set up core: $message")
                    showConfigError(message)
                    false
                }
            },
            onFailure = { error ->
                host.log("Unable to set up core: $error")
                showConfigError(error.message)
                false
            },
        )
    }

    private fun showConfigError(message: String?) {
        host.showToast(message?.takeIf { it.isNotBlank() } ?: INVALID_CONFIG_MESSAGE)
    }

    private suspend fun start(request: RunRequest): Boolean = startPreparationLock.withLock {
        val started = runStart(request)
        if (!started) {
            reconcileStopped()
        }
        started
    }

    private suspend fun runStart(request: RunRequest): Boolean {
        if (!isCurrent(request)) {
            return false
        }
        val options = sharedState.vpnOptions
        if (options == null) {
            fail(request)
            return false
        }
        if (!prepareVpn(options)) {
            if (host.app() == null && isCurrent(request)) {
                host.showToast(VPN_PERMISSION_MESSAGE)
            }
            fail(request)
            return false
        }
        if (!isCurrent(request)) {
            return false
        }

        return transitionLock.withLock transition@{
            if (!isCurrent(request)) {
                return@transition false
            }
            if (runTimeMillis != 0L && host.isVpnServiceActive() == options.enable) {
                // A start that lands on a paused service is a resume.
                if (host.pauseState.value.paused) {
                    host.resumeService()
                }
                mutableRunState.value = RunState.STARTED
                return@transition true
            }
            mutableRunState.value = RunState.STARTING
            val startedAtMillis = host.startService(options)
            if (startedAtMillis == 0L) {
                mutableRunState.value = RunState.STOPPED
                fail(request)
                return@transition false
            }
            if (!isCurrent(request)) {
                return@transition false
            }
            mutableRunState.value = RunState.STARTED
            true
        }
    }

    private suspend fun reconcileStopped() = transitionLock.withLock {
        if (isRunningRequested() || runTimeMillis == 0L) {
            return@withLock
        }
        mutableRunState.value = RunState.STOPPING
        host.stopService()
        mutableRunState.value = RunState.STOPPED
    }

    private suspend fun stop(request: RunRequest): Boolean = transitionLock.withLock {
        if (!isCurrent(request)) {
            return@withLock false
        }
        abandonVpnPreparation()
        if (runState.value == RunState.STOPPED && runTimeMillis == 0L) {
            return@withLock true
        }
        mutableRunState.value = RunState.STOPPING
        host.stopService()
        mutableRunState.value = RunState.STOPPED
        isCurrent(request)
    }

    private suspend fun pause(request: RunRequest): Boolean = transitionLock.withLock {
        if (!isCurrent(request)) {
            return@withLock false
        }
        if (runState.value != RunState.STARTED || runTimeMillis == 0L || !host.isVpnServiceActive()) {
            return@withLock false
        }
        host.pauseService(manual = true)
        // Only the service knows whether there was a TUN to tear down, so a refused
        // transition must leave the run state where it was.
        if (!host.pauseState.value.paused) {
            return@withLock false
        }
        mutableRunState.value = RunState.PAUSED
        isCurrent(request)
    }

    private suspend fun resume(request: RunRequest): Boolean = transitionLock.withLock {
        if (!isCurrent(request)) {
            return@withLock false
        }
        if (runState.value != RunState.PAUSED) {
            return@withLock false
        }
        host.resumeService()
        if (host.pauseState.value.paused) {
            return@withLock false
        }
        mutableRunState.value = RunState.STARTED
        isCurrent(request)
    }

    private suspend fun syncPaused(paused: Boolean) = transitionLock.withLock {
        mutableRunState.value = when {
            paused && runState.value == RunState.STARTED && runTimeMillis != 0L -> RunState.PAUSED
            !paused && runState.value == RunState.PAUSED -> RunState.STARTED
            else -> runState.value
        }
    }

    private suspend fun prepareVpn(options: VpnOptions): Boolean {
        val app = host.app()
            ?: return !options.enable || host.isVpnPermissionGranted()
        return suspendCancellableCoroutine { continuation ->
            val callback: (Boolean) -> Unit = { granted ->
                pendingVpnPreparation = null
                if (continuation.isActive) {
                    continuation.resume(granted)
                }
            }
            pendingVpnPreparation = {
                app.cancelVpnPreparation(callback)
                callback(false)
            }
            continuation.invokeOnCancellation {
                pendingVpnPreparation = null
                app.cancelVpnPreparation(callback)
            }
            app.prepareVpn(options.enable, callback)
        }
    }

    private fun abandonVpnPreparation() {
        val abandon = pendingVpnPreparation ?: return
        pendingVpnPreparation = null
        abandon()
    }

    private fun createRequest(running: Boolean, paused: Boolean = false): RunRequest =
        arbiter.request(running, paused)

    private fun isRunningRequested(): Boolean = arbiter.isRunningRequested

    private fun isCurrent(request: RunRequest): Boolean = arbiter.isCurrent(request)

    private fun fail(request: RunRequest) {
        arbiter.resetToStopped(request)
    }

    internal companion object {
        /**
         * The Core init payload. The key spelling is a cross-language contract with the Go wrapper,
         * not an implementation detail.
         */
        fun initParams(homeDirPath: String, sdkInt: Int): String = Gson().toJson(
            mapOf(
                "home-dir" to homeDirPath,
                "version" to sdkInt,
            ),
        )

        fun notificationParams(state: SharedState): NotificationParams = NotificationParams(
            title = state.currentProfileName,
            stopText = state.stopText,
            onlyStatisticsProxy = state.onlyStatisticsProxy,
            pauseText = state.pauseText,
            resumeText = state.resumeText,
        )
    }
}
