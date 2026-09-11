package com.reclash.service.modules

import android.app.KeyguardManager
import android.app.Notification.FOREGROUND_SERVICE_IMMEDIATE
import android.app.Service
import android.app.Service.STOP_FOREGROUND_REMOVE
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.content.getSystemService
import com.reclash.common.Components
import com.reclash.common.GlobalState
import com.reclash.common.QuickAction
import com.reclash.common.quickIntent
import com.reclash.common.receiveBroadcastFlow
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
    val channelId: String,
)

// A keyguard in front of the shade is the only moment the privacy setting is
// about; a dark screen hides the notification from nobody.
internal fun NotificationParams.extended(
    paused: Boolean,
    routing: SmartRoutingStatus,
    doctor: DoctorStatus,
    activeServer: String? = null,
    activeServerResolver: (() -> String?)? = null,
    locked: Boolean = false,
): ExtendedNotificationParams {
    if (locked && hideSensitiveOnLockScreen) {
        return ExtendedNotificationParams(
            title = "ReClash",
            stopText = stopText,
            pauseText = pauseText,
            resumeText = resumeText,
            paused = paused,
            showPauseAction = false,
            showStopAction = false,
            hideSensitiveOnLockScreen = hideSensitiveOnLockScreen,
            publicContentText = activeText,
            contentText = activeText,
            channelId = channelId,
        )
    }
    return ExtendedNotificationParams(
        title = title,
        stopText = stopText,
        pauseText = pauseText,
        resumeText = resumeText,
        paused = paused,
        showPauseAction = showPauseAction,
        showStopAction = showStopAction,
        hideSensitiveOnLockScreen = hideSensitiveOnLockScreen,
        publicContentText = activeText,
        contentText = if (paused) {
            pausedText
        } else {
            content(routing, doctor, activeServer ?: activeServerResolver?.invoke())
        },
        channelId = channelId,
    )
}

// A foreground service has to post, so the quieter levels post to a channel the
// app itself created at a lower importance instead of skipping the post.
internal val NotificationParams.channelId: String
    get() = when (visibility) {
        "minimal" -> GlobalState.NOTIFICATION_CHANNEL_QUIET
        "off" -> GlobalState.NOTIFICATION_CHANNEL_HIDDEN
        else -> GlobalState.NOTIFICATION_CHANNEL
    }

// Every other component is redrawn by its own event; only live counters need a
// clock, and only while somebody can read them.
internal val NotificationParams.needsTicker: Boolean
    get() = components.any { it.type == "speed" || it.type == "sessionTraffic" }

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
    private val pauseSupported: Boolean,
) : ServiceModule {
    override fun start() {
        update(currentParams())
        scope.launch {
            val screen = screenFlow().shareIn(this, SharingStarted.Eagerly, replay = 1)

            combine(
                ticker(screen),
                ServiceConfig.notificationParams,
                screen,
                ServiceConfig.pauseState,
                ServiceConfig.smartRoutingStatus,
                ServiceConfig.doctorStatus,
            ) { values ->
                val params = values[1] as NotificationParams
                params.extended(
                    paused = (values[3] as PauseState).paused,
                    routing = values[4] as SmartRoutingStatus,
                    doctor = values[5] as DoctorStatus,
                    activeServerResolver = { params.resolveActiveServer() },
                    locked = (values[2] as ScreenState).locked,
                )
            }.distinctUntilChanged()
                .collect(::update)
        }
    }

    private data class ScreenState(val interactive: Boolean, val locked: Boolean)

    private fun screenFlow(): Flow<ScreenState> = service.receiveBroadcastFlow {
        addAction(Intent.ACTION_SCREEN_ON)
        addAction(Intent.ACTION_SCREEN_OFF)
        addAction(Intent.ACTION_USER_PRESENT)
    }.map { screenState() }
        .onStart { emit(screenState()) }
        .distinctUntilChanged()

    @OptIn(ExperimentalCoroutinesApi::class)
    private fun ticker(screen: Flow<ScreenState>): Flow<Unit> = combine(
        ServiceConfig.notificationParams.map { it.needsTicker }.distinctUntilChanged(),
        screen.map { it.interactive }.distinctUntilChanged(),
    ) { needed, interactive -> needed && interactive }
        .distinctUntilChanged()
        .flatMapLatest { live ->
            if (live) {
                flow {
                    while (true) {
                        emit(Unit)
                        delay(1_000)
                    }
                }
            } else {
                flowOf(Unit)
            }
        }

    private fun currentParams(): ExtendedNotificationParams {
        val params = ServiceConfig.notificationParams.value
        return params.extended(
            paused = ServiceConfig.pauseState.value.paused,
            routing = ServiceConfig.smartRoutingStatus.value,
            doctor = ServiceConfig.doctorStatus.value,
            activeServerResolver = { params.resolveActiveServer() },
            locked = screenState().locked,
        )
    }

    private fun NotificationParams.resolveActiveServer(): String? {
        val component = components.firstOrNull { it.type == "currentServer" } ?: return null
        val group = component.group ?: activeServerGroup ?: return null
        return runCatching { Core.getActiveServerState(group) }.getOrNull()
    }

    private fun screenState() = ScreenState(
        interactive = service.getSystemService<PowerManager>()?.isInteractive != false,
        locked = service.getSystemService<KeyguardManager>()?.isKeyguardLocked == true,
    )

    private val builders = mutableMapOf<String, NotificationCompat.Builder>()

    // Pre-O has no channels, so the priority is the only lever a quieter level
    // has there.
    private fun builderFor(channelId: String): NotificationCompat.Builder =
        builders.getOrPut(channelId) {
            val intent = Intent().setComponent(Components.mainActivity)
            val priority = if (channelId == GlobalState.NOTIFICATION_CHANNEL) {
                NotificationCompat.PRIORITY_LOW
            } else {
                NotificationCompat.PRIORITY_MIN
            }

            NotificationCompat.Builder(service, channelId).apply {
                setSmallIcon(R.drawable.ic_service)
                setContentTitle("ReClash")
                setContentIntent(intent.toPendingIntent)
                setPriority(priority)
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
            with(builderFor(params.channelId)) {
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
                            NotificationCompat.Builder(service, params.channelId)
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
            params.channelId,
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
