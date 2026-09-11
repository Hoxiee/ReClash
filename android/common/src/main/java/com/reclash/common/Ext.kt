package com.reclash.common

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Context.RECEIVER_NOT_EXPORTED
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
import android.os.Build
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlin.reflect.KClass

val KClass<*>.intent: Intent
    get() = Intent(GlobalState.application, this.java)

val ComponentName.intent: Intent
    get() = Intent().apply {
        component = this@intent
    }

val QuickAction.action: String
    get() = "${GlobalState.application.packageName}.action.${this.name}"

val QuickAction.quickIntent: Intent
    get() = Components.quickActionActivity.intent.apply {
        action = this@quickIntent.action
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
    }

val BroadcastAction.action: String
    get() = "${GlobalState.application.packageName}.intent.action.${this.name}"

fun BroadcastAction.sendBroadcast() {
    val broadcastAction = action
    val intent = Intent(broadcastAction).apply {
        component = Components.serviceBroadcastReceiver
    }
    GlobalState.log("Send broadcast: $broadcastAction")
    GlobalState.application.sendBroadcast(
        intent,
        GlobalState.receiveBroadcastPermission,
    )
}

val Intent.toPendingIntent: PendingIntent
    get() = PendingIntent.getActivity(
        GlobalState.application,
        0,
        this,
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

// Channel importance is immutable and AMS drops the old post only when the id changes.
fun serviceChannelImportance(channelId: String): Int = when (channelId) {
    GlobalState.NOTIFICATION_CHANNEL_QUIET -> NotificationManager.IMPORTANCE_MIN
    GlobalState.NOTIFICATION_CHANNEL_HIDDEN -> NotificationManager.IMPORTANCE_NONE
    else -> NotificationManager.IMPORTANCE_LOW
}

fun serviceChannelName(channelId: String): Int = when (channelId) {
    GlobalState.NOTIFICATION_CHANNEL_QUIET -> R.string.service_channel_quiet_name
    GlobalState.NOTIFICATION_CHANNEL_HIDDEN -> R.string.service_channel_hidden_name
    else -> R.string.service_channel_name
}

fun serviceNotificationId(channelId: String): Int = when (channelId) {
    GlobalState.NOTIFICATION_CHANNEL_QUIET -> GlobalState.NOTIFICATION_ID_QUIET
    GlobalState.NOTIFICATION_CHANNEL_HIDDEN -> GlobalState.NOTIFICATION_ID_HIDDEN
    else -> GlobalState.NOTIFICATION_ID
}

fun Service.startForeground(
    notification: Notification,
    channelId: String = GlobalState.NOTIFICATION_CHANNEL,
) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val manager = getSystemService(NotificationManager::class.java)
        if (manager?.getNotificationChannel(channelId) == null) {
            manager?.createNotificationChannel(
                NotificationChannel(
                    channelId,
                    getString(serviceChannelName(channelId)),
                    serviceChannelImportance(channelId),
                ),
            )
        }
    }
    val notificationId = serviceNotificationId(channelId)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        startForeground(
            notificationId,
            notification,
            FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
        )
    } else {
        startForeground(notificationId, notification)
    }
}

@SuppressLint("UnspecifiedRegisterReceiverFlag")
fun Context.registerReceiverCompat(
    receiver: BroadcastReceiver,
    filter: IntentFilter,
) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    registerReceiver(receiver, filter, RECEIVER_NOT_EXPORTED)
} else {
    registerReceiver(receiver, filter)
}

fun Context.receiveBroadcastFlow(
    configure: IntentFilter.() -> Unit,
): Flow<Intent> = callbackFlow {
    val filter = IntentFilter().apply(configure)
    val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (context == null || intent == null) return
            trySend(intent)
        }
    }
    registerReceiverCompat(receiver, filter)
    awaitClose { unregisterReceiver(receiver) }
}
