package com.reclash.service.modules

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
import com.reclash.service.R
import com.reclash.service.ServiceConfig
import com.reclash.service.models.NotificationParams
import com.reclash.service.models.getSpeedTrafficText
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch

private data class ExtendedNotificationParams(
    val title: String,
    val stopText: String,
    val pauseText: String,
    val resumeText: String,
    val paused: Boolean,
    val contentText: String,
)

private fun NotificationParams.extended(paused: Boolean) = ExtendedNotificationParams(
    title,
    stopText,
    pauseText,
    resumeText,
    paused,
    if (paused) pauseText else Core.getSpeedTrafficText(onlyStatisticsProxy),
)

internal class NotificationModule(
    private val service: Service,
    private val scope: CoroutineScope,
) : ServiceModule {
    override fun start() {
        update(ServiceConfig.notificationParams.value.extended(ServiceConfig.pauseState.value.paused))
        scope.launch {
            val screenFlow = service.receiveBroadcastFlow {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
            }.map { intent ->
                intent.action == Intent.ACTION_SCREEN_ON
            }.onStart {
                emit(isScreenOn())
            }

            combine(
                flow {
                    while (true) {
                        delay(1_000)
                        emit(Unit)
                    }
                },
                ServiceConfig.notificationParams,
                screenFlow,
                ServiceConfig.pauseState,
            ) { _, params, screenOn, pauseState ->
                params.takeIf { screenOn }?.extended(pauseState.paused)
            }.filterNotNull()
                .distinctUntilChanged()
                .collect(::update)
        }
    }

    private fun isScreenOn() =
        service.getSystemService<PowerManager>()?.isInteractive ?: true

    private val notificationBuilder: NotificationCompat.Builder by lazy {
        val intent = Intent().setComponent(Components.mainActivity)

        NotificationCompat.Builder(
            service,
            GlobalState.NOTIFICATION_CHANNEL,
        ).apply {
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
        service.startForeground(
            with(notificationBuilder) {
                setContentTitle(params.title)
                setContentText(params.contentText)
                clearActions()
                addAction(0, toggleText, toggleAction.quickIntent.toPendingIntent)
                addAction(0, params.stopText, QuickAction.STOP.quickIntent.toPendingIntent)
                    .build()
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
