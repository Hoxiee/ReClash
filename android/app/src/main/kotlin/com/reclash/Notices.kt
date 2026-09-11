package com.reclash

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.net.toUri
import com.reclash.common.Components
import com.reclash.common.R as CommonR
import com.reclash.common.intent
import com.reclash.common.toPendingIntent
import com.reclash.service.R as ServiceR

internal const val SUBSCRIPTION_NOTICE_CHANNEL = "reclash_subscription_reminders"
private const val SUBSCRIPTION_NOTICE_ID_BASE = 2_000

internal fun subscriptionNoticeId(key: String): Int =
    SUBSCRIPTION_NOTICE_ID_BASE + (key.hashCode() and 0x3fffffff)

// Panels supply this URL, so any other scheme could aim the button anywhere.
internal fun openableUrl(url: String?): String? {
    val value = url?.trim() ?: return null
    if (value.any { it.isWhitespace() }) return null
    val scheme = value.substringBefore("://", "").lowercase()
    if (scheme != "http" && scheme != "https") return null
    if (value.length <= scheme.length + 3) return null
    return scheme + value.substring(scheme.length)
}

internal fun Context.showNotice(
    channelName: String,
    notificationKey: String,
    title: String,
    message: String,
    actionLabel: String?,
    actionUrl: String?,
): Boolean {
    val manager = NotificationManagerCompat.from(this)
    if (!manager.areNotificationsEnabled()) return false
    ensureSubscriptionChannel(channelName)
    if (!isChannelEnabled(SUBSCRIPTION_NOTICE_CHANNEL)) return false
    val builder = NotificationCompat.Builder(this, SUBSCRIPTION_NOTICE_CHANNEL)
        .setSmallIcon(ServiceR.drawable.ic_service)
        .setContentTitle(title)
        .setContentText(message)
        .setStyle(NotificationCompat.BigTextStyle().bigText(message))
        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
        .setCategory(NotificationCompat.CATEGORY_REMINDER)
        .setAutoCancel(true)
        .setContentIntent(Components.mainActivity.intent.toPendingIntent)
    val url = openableUrl(actionUrl)
    if (url != null && !actionLabel.isNullOrEmpty()) {
        val open = Intent(Intent.ACTION_VIEW, url.toUri())
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        builder.addAction(0, actionLabel, open.toPendingIntent)
    }
    manager.notify(subscriptionNoticeId(notificationKey), builder.build())
    return true
}

internal fun Context.isChannelEnabled(channelId: String): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return true
    val manager = getSystemService(NotificationManager::class.java) ?: return false
    val channel = manager.getNotificationChannel(channelId) ?: return true
    return channel.importance != NotificationManager.IMPORTANCE_NONE
}

private fun Context.ensureSubscriptionChannel(channelName: String) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
    val manager = getSystemService(NotificationManager::class.java) ?: return
    manager.createNotificationChannel(
        NotificationChannel(
            SUBSCRIPTION_NOTICE_CHANNEL,
            channelName.ifBlank { getString(CommonR.string.service_channel_name) },
            NotificationManager.IMPORTANCE_DEFAULT,
        ),
    )
}
