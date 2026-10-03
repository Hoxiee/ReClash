package com.reclash.service.modules

import android.app.Notification.FOREGROUND_SERVICE_IMMEDIATE
import android.app.Service
import android.app.Service.STOP_FOREGROUND_REMOVE
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.reclash.common.Components
import com.reclash.common.GlobalState
import com.reclash.common.QuickAction
import com.reclash.common.quickIntent
import com.reclash.common.startForeground
import com.reclash.common.toPendingIntent
import com.reclash.core.Core
import com.reclash.service.DoctorStatus
import com.reclash.service.PauseState
import com.reclash.service.R
import com.reclash.service.ServiceConfig
import com.reclash.service.SmartRoutingStatus
import com.reclash.service.models.NotificationComponent
import com.reclash.service.models.NotificationParams
import com.reclash.service.models.getActiveServerState
import com.reclash.service.models.getTotalTrafficState
import com.reclash.service.models.getTrafficState
import com.reclash.service.models.speedText
import com.reclash.service.models.totalText
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch

internal data class ExtendedNotificationParams(
    val title: String,
    val stopText: String,
    val pauseText: String,
    val resumeText: String,
    val paused: Boolean,
    val showPauseAction: Boolean,
    val showStopAction: Boolean,
    val hideSensitiveOnLockScreen: Boolean,
    val publicContentText: String,
    val contentText: String,
)

// The public version handles lock-screen redaction; swapping content on a keyguard broadcast flashes the real title.
internal fun NotificationParams.extended(
    paused: Boolean,
    routing: SmartRoutingStatus,
    doctor: DoctorStatus,
    activeServer: String? = null,
    activeServerResolver: (() -> String?)? = null,
): ExtendedNotificationParams {
    val detailed = visibility == "detailed"
    return ExtendedNotificationParams(
        title = if (detailed) title else "ReClash",
        stopText = stopText,
        pauseText = pauseText,
        resumeText = resumeText,
        paused = paused,
        showPauseAction = detailed && showPauseAction,
        showStopAction = detailed && showStopAction,
        hideSensitiveOnLockScreen = hideSensitiveOnLockScreen,
        publicContentText = if (paused) pausedText else neutralActiveText,
        contentText = when {
            paused -> pausedText
            !detailed -> neutralActiveText
            else -> content(routing, doctor, activeServer ?: activeServerResolver?.invoke())
        },
    )
}

internal val NotificationParams.updateIntervalMillis: Long?
    get() = when {
        visibility != "detailed" -> null
        components.any { it.type == "speed" || it.type == "sessionTraffic" } -> 1_000L
        components.any { it.type == "currentServer" } && !activeServerGroup.isNullOrBlank() -> 2_000L
        else -> null
    }

@OptIn(ExperimentalCoroutinesApi::class)
internal fun notificationTicks(
    params: Flow<NotificationParams>,
    pause: Flow<PauseState>,
    screenOn: Flow<Boolean>,
): Flow<Unit> = combine(
    params.map { it.updateIntervalMillis },
    pause.map { it.paused },
    screenOn,
) { interval, paused, visible -> interval.takeIf { visible && !paused } }
    .distinctUntilChanged()
    .flatMapLatest { interval ->
        if (interval == null) {
            flowOf(Unit)
        } else {
            flow {
                while (true) {
                    emit(Unit)
                    delay(interval)
                }
            }
        }
    }

internal fun notificationUpdates(
    params: Flow<NotificationParams>,
    pause: Flow<PauseState>,
    routing: Flow<SmartRoutingStatus>,
    doctor: Flow<DoctorStatus>,
    screenOn: Flow<Boolean>,
    resolveServer: (String) -> String?,
): Flow<ExtendedNotificationParams> = combine(
    notificationTicks(params, pause, screenOn),
    params,
    pause,
    routing,
    doctor,
) { _, current, pauseState, routingStatus, doctorStatus ->
    current.extended(
        paused = pauseState.paused,
        routing = routingStatus,
        doctor = doctorStatus,
        activeServerResolver = { current.resolveActiveServer(resolveServer) },
    )
}.distinctUntilChanged()

internal fun NotificationParams.resolveActiveServer(resolveServer: (String) -> String?): String? {
    if (components.none { it.type == "currentServer" }) return null
    val group = activeServerGroup?.trim()?.takeIf(String::isNotBlank) ?: return null
    return runCatching { resolveServer(group) }.getOrNull()
}

internal fun NotificationParams.projectContent(
    routing: SmartRoutingStatus,
    doctor: DoctorStatus,
    activeServer: String?,
    traffic: String?,
    trafficIdle: Boolean,
    sessionTraffic: String?,
): String = components.mapNotNull { component ->
    projectComponent(
        component = component,
        routing = routing,
        doctor = doctor,
        activeServer = activeServer,
        traffic = traffic,
        trafficIdle = trafficIdle,
        sessionTraffic = sessionTraffic,
    )
}.joinToString("\n").ifBlank { activeText }

private fun NotificationParams.projectComponent(
    component: NotificationComponent,
    routing: SmartRoutingStatus,
    doctor: DoctorStatus,
    activeServer: String?,
    traffic: String?,
    trafficIdle: Boolean,
    sessionTraffic: String?,
): String? = when (component.type) {
    "connectionDoctor" -> doctorText(doctor, component.doctorPriority ?: "problems")
    "networkState" -> networkText(routing)
    "currentServer" -> activeServer
        ?.takeIf(String::isNotBlank)
        ?.let { "$currentServerText · $it" }
    "smartRouting" -> routingText(routing)
    "speed" -> traffic?.takeUnless {
        component.hideWhenIdle != false && trafficIdle
    }
    "sessionTraffic" -> sessionTraffic
        ?.takeIf(String::isNotBlank)
        ?.let { "$sessionTrafficText · $it" }
    else -> null
}

private fun NotificationParams.content(
    routing: SmartRoutingStatus,
    doctor: DoctorStatus,
    activeServer: String?,
): String {
    val needsSpeed = components.any { it.type == "speed" }
    val needsSessionTraffic = components.any { it.type == "sessionTraffic" }
    val traffic = if (needsSpeed) Core.getTrafficState(onlyStatisticsProxy) else null
    return projectContent(
        routing = routing,
        doctor = doctor,
        activeServer = activeServer,
        traffic = traffic?.speedText,
        trafficIdle = traffic?.isIdle ?: true,
        sessionTraffic = if (needsSessionTraffic) {
            Core.getTotalTrafficState(onlyStatisticsProxy)?.totalText
        } else {
            null
        },
    )
}

private fun NotificationParams.networkText(status: SmartRoutingStatus): String? {
    if (!status.enabled) return null
    val terrain = when (status.terrain) {
        "normal" -> networkNormalText
        "whitelist" -> networkWhitelistText
        "portal" -> networkPortalText
        "offline" -> networkOfflineText
        else -> networkUnknownText
    }
    return "$networkStateText · $terrain"
}

private fun NotificationParams.routingText(status: SmartRoutingStatus): String? = when {
    !status.enabled -> null
    status.searching -> "$smartRoutingText · $smartRoutingSearchingText"
    status.node.isNotBlank() && status.delay > 0 -> {
        "$smartRoutingText · ${status.node} · ${status.delay}ms"
    }
    status.node.isNotBlank() -> "$smartRoutingText · ${status.node}"
    else -> null
}

private fun NotificationParams.doctorText(
    status: DoctorStatus,
    priority: String,
): String? {
    val isProblem = status.health == "degraded" ||
        status.health == "broken" ||
        status.state == "examining"
    if (priority == "never" || (priority != "always" && !isProblem)) {
        return null
    }
    val statusText = when {
        status.state == "examining" -> doctorExaminingText
        status.health == "broken" -> doctorBrokenText
        status.health == "degraded" -> doctorDegradedText
        status.health == "healthy" -> doctorHealthyText
        else -> doctorObservingText
    }
    return "$connectionDoctorText · $statusText"
}

internal class NotificationModule(
    private val service: Service,
    private val scope: CoroutineScope,
    private val screenState: ScreenState,
    private val pauseSupported: Boolean,
) : ServiceModule {
    override fun start() {
        update(currentParams())
        scope.launch {
            notificationUpdates(
                params = ServiceConfig.notificationParams,
                pause = ServiceConfig.pauseState,
                routing = ServiceConfig.smartRoutingStatus,
                doctor = ServiceConfig.doctorStatus,
                screenOn = screenState.state.map { it.screenOn },
                resolveServer = { Core.getActiveServerState(it) },
            ).collect(::update)
        }
    }

    private fun currentParams(): ExtendedNotificationParams {
        val params = ServiceConfig.notificationParams.value
        return params.extended(
            paused = ServiceConfig.pauseState.value.paused,
            routing = ServiceConfig.smartRoutingStatus.value,
            doctor = ServiceConfig.doctorStatus.value,
            activeServerResolver = {
                params.resolveActiveServer { Core.getActiveServerState(it) }
            },
        )
    }

    private val builder: NotificationCompat.Builder by lazy {
        val intent = Intent().setComponent(Components.mainActivity)
        NotificationCompat.Builder(service, GlobalState.NOTIFICATION_CHANNEL).apply {
            setSmallIcon(R.drawable.ic_service)
            setContentTitle("ReClash")
            setContentIntent(intent.toPendingIntent)
            setPriority(NotificationCompat.PRIORITY_LOW)
            setCategory(NotificationCompat.CATEGORY_SERVICE)
            setOngoing(true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                foregroundServiceBehavior = FOREGROUND_SERVICE_IMMEDIATE
            }
            setShowWhen(true)
            setOnlyAlertOnce(true)
        }
    }

    private fun update(params: ExtendedNotificationParams) {
        val toggleAction = if (params.paused) QuickAction.RESUME else QuickAction.PAUSE
        val toggleText = if (params.paused) params.resumeText else params.pauseText
        val toggleIcon = if (params.paused) {
            R.drawable.ic_action_resume
        } else {
            R.drawable.ic_action_pause
        }
        service.startForeground(
            with(builder) {
                setContentTitle(params.title)
                setContentText(params.contentText.lineSequence().firstOrNull())
                setStyle(
                    params.contentText
                        .takeIf { it.contains('\n') }
                        ?.let(NotificationCompat.BigTextStyle()::bigText),
                )
                setVisibility(
                    if (params.hideSensitiveOnLockScreen) {
                        setPublicVersion(
                            NotificationCompat.Builder(service, GlobalState.NOTIFICATION_CHANNEL)
                                .setSmallIcon(R.drawable.ic_service)
                                .setContentTitle("ReClash")
                                .setContentText(params.publicContentText)
                                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                                .setOngoing(true)
                                .build(),
                        )
                        NotificationCompat.VISIBILITY_PRIVATE
                    } else {
                        setPublicVersion(null)
                        NotificationCompat.VISIBILITY_PUBLIC
                    },
                )
                clearActions()
                if (pauseSupported && params.showPauseAction) {
                    addAction(
                        toggleIcon,
                        toggleText,
                        toggleAction.quickIntent.toPendingIntent,
                    )
                }
                if (params.showStopAction) {
                    addAction(
                        R.drawable.ic_action_stop,
                        params.stopText,
                        QuickAction.STOP.quickIntent.toPendingIntent,
                    )
                }
                build()
            },
        )
    }

    @Suppress("DEPRECATION")
    override fun stop() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            service.stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            service.stopForeground(true)
        }
    }
}
