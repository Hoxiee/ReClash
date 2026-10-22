package com.reclash

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.net.toUri
import java.net.URI
import com.reclash.common.Components
import com.reclash.common.R as CommonR
import com.reclash.common.intent
import com.reclash.common.toPendingIntent
import com.reclash.service.R as ServiceR

internal const val SUBSCRIPTION_NOTICE_CHANNEL = "reclash_subscription_reminders"
private const val SUBSCRIPTION_NOTICE_ID = 2_000

internal fun openableUrl(url: String?): String? = runCatching {
    val value = url?.trim() ?: return null
    val uri = URI(value)
    value.takeIf {
        uri.scheme?.lowercase() in setOf("http", "https") &&
            !uri.host.isNullOrBlank() && uri.userInfo == null
    }
}.getOrNull()

internal data class NoticePrivacy(val visibility: Int, val publicMessage: String?)

internal fun noticePrivacy(hideSensitiveOnLockScreen: Boolean, publicMessage: String): NoticePrivacy =
    if (hideSensitiveOnLockScreen) {
        NoticePrivacy(NotificationCompat.VISIBILITY_PRIVATE, publicMessage)
    } else {
        NoticePrivacy(NotificationCompat.VISIBILITY_PUBLIC, null)
    }

internal fun Context.showNotice(
    channelName: String,
    notificationKey: String,
    title: String,
    message: String,
    hideSensitiveOnLockScreen: Boolean,
    publicMessage: String,
    actionLabel: String?,
    actionUrl: String?,
): Boolean {
    val manager = NotificationManagerCompat.from(this)
    if (!manager.areNotificationsEnabled()) return false
    ensureSubscriptionChannel(channelName)
    if (!isChannelEnabled(SUBSCRIPTION_NOTICE_CHANNEL)) return false
    val privacy = noticePrivacy(hideSensitiveOnLockScreen, publicMessage)
    val publicVersion = privacy.publicMessage?.let { text ->
        NotificationCompat.Builder(this, SUBSCRIPTION_NOTICE_CHANNEL)
            .setSmallIcon(ServiceR.drawable.ic)
            .setContentTitle("ReClash")
            .setContentText(text)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .build()
    }
    val builder = NotificationCompat.Builder(this, SUBSCRIPTION_NOTICE_CHANNEL)
        .setSmallIcon(ServiceR.drawable.ic)
        .setVisibility(privacy.visibility)
        .setPublicVersion(publicVersion)
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
    manager.notify(notificationKey, SUBSCRIPTION_NOTICE_ID, builder.build())
    return true
}

internal fun Context.isChannelEnabled(channelId: String): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return true
    val manager = getSystemService(NotificationManager::class.java) ?: return false
    val channel = manager.getNotificationChannel(channelId) ?: return true
    return channel.importance != NotificationManager.IMPORTANCE_NONE
}

internal fun Context.ensureSubscriptionChannel(channelName: String) {
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
