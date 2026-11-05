package com.reclash.service

import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.Network
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.reclash.common.Components
import com.reclash.common.GlobalState
import com.reclash.common.ensureNotificationChannel
import com.reclash.common.startForeground
import com.reclash.common.toPendingIntent
import com.reclash.core.Core
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * The relay's desired state. It is written here, on the platform thread, and
 * persisted, because Android restarts a sticky service with no intent and no
 * Flutter engine: Telegram goes offline when the relay dies, so the relay has to
 * come back without the app.
 */
object TelegramProxy {
    private const val PREFERENCES = "telegram_proxy"
    private const val KEY_PARAMS = "params"
    private const val KEY_AUTOSTART = "autostart"
    private const val KEY_STOPPED_BY_USER = "stoppedByUser"

    @Volatile
    internal var serviceRunning = false

    private val mutableStops = MutableStateFlow(0L)
    val stops = mutableStops.asStateFlow()

    private val preferences
        get() = GlobalState.application.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    val desiredParams: String?
        get() = preferences.getString(KEY_PARAMS, null)

    val autostart: Boolean
        get() = preferences.getBoolean(KEY_AUTOSTART, false)

    fun request(context: Context, params: String?, autostart: Boolean) {
        preferences.edit()
            .putString(KEY_PARAMS, params)
            .putBoolean(KEY_AUTOSTART, autostart)
            .putBoolean(KEY_STOPPED_BY_USER, false)
            .apply()
        if (params == null) invoke(params = null)
        // Off also goes through the service while it runs: a stopService that overtakes a
        // pending startForegroundService crashes the app with a missed startForeground.
        if (params != null || serviceRunning) {
            ContextCompat.startForegroundService(context, Intent(context, TelegramProxyService::class.java))
        }
    }

    fun stopFromNotification() {
        preferences.edit()
            .putString(KEY_PARAMS, null)
            .putBoolean(KEY_STOPPED_BY_USER, true)
            .apply()
        invoke(params = null)
        mutableStops.value++
    }

    fun consumeStoppedByUser(): Boolean {
        val stopped = preferences.getBoolean(KEY_STOPPED_BY_USER, false)
        if (stopped) preferences.edit().putBoolean(KEY_STOPPED_BY_USER, false).apply()
        return stopped
    }

    fun invoke(params: String?) {
        val arguments = params?.let { Gson().fromJson(it, JsonObject::class.java) }
            ?: JsonObject().apply { addProperty("enabled", false) }
        call("setTelegramProxy", arguments)
    }

    fun resetConnections() = call("telegramProxyResetConnections", null)

    private fun call(method: String, arguments: JsonObject?) {
        val data = JsonObject().apply {
            addProperty("method", method)
            add("arguments", arguments)
        }
        Core.invokeMethod(data.toString()) {}
    }
}

class TelegramProxyService : Service() {
    private var lastNetwork: Network? = null
    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            val changed = lastNetwork != null && lastNetwork != network
            lastNetwork = network
            if (changed) TelegramProxy.resetConnections()
        }
    }

    override fun onBind(intent: Intent): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        TelegramProxy.serviceRunning = true
        getSystemService(ConnectivityManager::class.java)?.registerDefaultNetworkCallback(networkCallback)
    }

    override fun onDestroy() {
        TelegramProxy.serviceRunning = false
        getSystemService(ConnectivityManager::class.java)?.unregisterNetworkCallback(networkCallback)
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val params = TelegramProxy.desiredParams
        // startForegroundService obliges a startForeground even when the answer is to stop.
        startForeground(buildNotification(params), GlobalState.TELEGRAM_PROXY_NOTIFICATION_ID)
        if (intent?.action == ACTION_STOP) {
            TelegramProxy.stopFromNotification()
            stopSelf()
            return START_NOT_STICKY
        }
        if (params == null) {
            stopSelf()
            return START_NOT_STICKY
        }
        TelegramProxy.invoke(params)
        return START_STICKY
    }

    private fun buildNotification(params: String?): android.app.Notification {
        ensureNotificationChannel()
        val labels = params?.let { Gson().fromJson(it, JsonObject::class.java) }
        val stopIntent = Intent(this, TelegramProxyService::class.java).setAction(ACTION_STOP)
        val stop = PendingIntent.getForegroundService(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val open = Intent(Intent.ACTION_MAIN).apply {
            component = Components.mainActivity
            addCategory(Intent.CATEGORY_LAUNCHER)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return NotificationCompat.Builder(this, GlobalState.NOTIFICATION_CHANNEL).apply {
            setSmallIcon(R.drawable.ic)
            setContentTitle(labels?.get("notificationTitle")?.asString ?: "Telegram")
            setContentIntent(open.toPendingIntent)
            setPriority(NotificationCompat.PRIORITY_LOW)
            setCategory(NotificationCompat.CATEGORY_SERVICE)
            setOngoing(true)
            setOnlyAlertOnce(true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                foregroundServiceBehavior = NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE
            }
            addAction(0, labels?.get("notificationStop")?.asString ?: "Stop", stop)
        }.build()
    }

    private companion object {
        const val ACTION_STOP = "com.reclash.service.TELEGRAM_PROXY_STOP"
    }
}

class TelegramProxyBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        if (TelegramProxy.desiredParams == null || !TelegramProxy.autostart) return
        ContextCompat.startForegroundService(context, Intent(context, TelegramProxyService::class.java))
    }
}
