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
import com.reclash.common.ensureNotificationChannel
import com.reclash.common.quickIntent
import com.reclash.common.receiveBroadcastFlow
import com.reclash.common.startForeground
import com.reclash.common.toPendingIntent
import com.reclash.service.R
import com.reclash.service.ServiceConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch

internal class NotificationModule(
    private val service: Service,
    private val scope: CoroutineScope,
) : ServiceModule {
    override fun start() {
        service.ensureNotificationChannel()
        update(ServiceConfig.notificationParams.value.extended)
        scope.launch {
            val screenOn = service.receiveBroadcastFlow(exported = true) {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
                addAction(Intent.ACTION_USER_PRESENT)
            }.map { it.action != Intent.ACTION_SCREEN_OFF }
                .onStart { emit(isScreenOn()) }
            notificationUpdates(ServiceConfig.notificationParams, screenOn)
                .map { it.extended }
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
            setSmallIcon(R.drawable.ic)
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

    private val stopIntent by lazy { QuickAction.STOP.quickIntent.toPendingIntent }

    private fun update(params: ExtendedNotificationParams) {
        service.startForeground(
            with(notificationBuilder) {
                setContentTitle(params.title)
                setContentText(params.contentText.lineSequence().firstOrNull())
                setStyle(params.contentText.takeIf { it.contains('\n') }?.let(NotificationCompat.BigTextStyle()::bigText))
                setVisibility(if (params.hideSensitive) NotificationCompat.VISIBILITY_PRIVATE else NotificationCompat.VISIBILITY_PUBLIC)
                setPublicVersion(if (params.hideSensitive) {
                    NotificationCompat.Builder(service, GlobalState.NOTIFICATION_CHANNEL)
                        .setSmallIcon(R.drawable.ic)
                        .setContentTitle("ReClash")
                        .setContentText(params.publicText)
                        .setOngoing(true)
                        .setCategory(NotificationCompat.CATEGORY_SERVICE)
                        .build()
                } else null)
                clearActions()
                if (params.showStopAction) {
                    addAction(0, params.stopText, stopIntent)
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
