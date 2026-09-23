package com.reclash.companion

import android.app.Notification
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import com.reclash.common.GlobalState
import com.reclash.common.R as CommonR
import com.reclash.service.R as ServiceR
import kotlinx.coroutines.launch

// GATE A: companion receiver as a connectedDevice FGS. It never creates a VPN binding; it only
// hosts the LAN HTTPS listener. START_NOT_STICKY and no BOOT autostart in the first version:
// process death honestly makes the TV unreachable until the app is opened again.
class CompanionService : Service() {
    private var server: CompanionServer? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundCompat()
        when (intent?.action) {
            ACTION_RUN_GATE -> GlobalState.launch(kotlinx.coroutines.Dispatchers.IO) {
                val outcome = CompanionGateRunner(applicationContext).run()
                GlobalState.log("CompanionGate result: $outcome")
            }
            ACTION_PROBE_ENGINE -> probeRetainedEngine()
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        server?.stop()
        server = null
        super.onDestroy()
    }

    // GATE B: a reply from the retained engine with no Activity proves the isolate survived teardown.
    private fun probeRetainedEngine() {
        val engine = io.flutter.embedding.engine.FlutterEngineCache.getInstance().get(ENGINE_ID)
        if (engine == null) {
            GlobalState.log("CompanionProbe result: {alive=false, reason=no-cached-engine}")
            return
        }
        android.os.Handler(mainLooper).post {
            io.flutter.plugin.common.MethodChannel(engine.dartExecutor.binaryMessenger, PROBE_CHANNEL)
                .invokeMethod(
                    "probeEngine",
                    null,
                    object : io.flutter.plugin.common.MethodChannel.Result {
                        override fun success(result: Any?) =
                            GlobalState.log("CompanionProbe result: $result")

                        override fun error(code: String, message: String?, details: Any?) =
                            GlobalState.log("CompanionProbe result: {alive=false, code=$code}")

                        override fun notImplemented() =
                            GlobalState.log("CompanionProbe result: {alive=false, reason=not-implemented}")
                    },
                )
        }
    }

    private fun startForegroundCompat() {
        val channelId = GlobalState.NOTIFICATION_CHANNEL
        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(ServiceR.drawable.ic_service)
            .setContentTitle(getString(CommonR.string.app_name))
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE
        } else {
            0
        }
        ServiceCompat.startForeground(this, NOTIFICATION_ID, notification, type)
    }

    companion object {
        private const val NOTIFICATION_ID = 7
        private const val ENGINE_ID = "reclash_main_engine"
        private const val PROBE_CHANNEL = "com.reclash/companion_gate"
        const val ACTION_RUN_GATE = "com.reclash.companion.RUN_GATE"
        const val ACTION_PROBE_ENGINE = "com.reclash.companion.PROBE_ENGINE"

        fun start(context: Context) {
            val intent = Intent(context, CompanionService::class.java)
            androidx.core.content.ContextCompat.startForegroundService(context, intent)
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CompanionService::class.java))
        }
    }
}
