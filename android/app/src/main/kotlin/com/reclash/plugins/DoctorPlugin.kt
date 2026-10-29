package com.reclash.plugins

import android.app.Activity
import android.app.Application
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.VpnService
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.provider.Settings
import com.reclash.common.Components
import com.reclash.common.PendingCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class DoctorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    EventChannel.StreamHandler {

    private lateinit var context: Context

    private lateinit var methodChannel: MethodChannel

    private lateinit var eventChannel: EventChannel

    private var activityBinding: ActivityPluginBinding? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    private val pendingVpn = PendingCallback<Boolean>()

    private val pendingSettings = PendingCallback<Boolean>()

    private var events: EventChannel.EventSink? = null

    private var lastPublished: Map<String, Any?>? = null

    private val connectivityManager: ConnectivityManager
        get() = context.getSystemService(ConnectivityManager::class.java)

    private val activityResultListener =
        PluginRegistry.ActivityResultListener { requestCode, resultCode, _ ->
            when (requestCode) {
                REQUEST_VPN -> {
                    val granted = resultCode == Activity.RESULT_OK
                    if (granted) {
                        rememberGranted()
                    }
                    pendingVpn.resolve(granted)
                    publish()
                    true
                }

                REQUEST_SETTINGS -> {
                    pendingSettings.resolve(true)
                    publish()
                    true
                }

                else -> false
            }
        }

    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) = publishLater()

        override fun onLost(network: Network) = publishLater()

        override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) =
            publishLater()

        override fun onLinkPropertiesChanged(
            network: Network,
            linkProperties: LinkProperties,
        ) = publishLater()
    }

    private val lifecycleCallbacks = object : Application.ActivityLifecycleCallbacks {
        override fun onActivityResumed(activity: Activity) = publish()

        override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}

        override fun onActivityStarted(activity: Activity) {}

        override fun onActivityPaused(activity: Activity) {}

        override fun onActivityStopped(activity: Activity) {}

        override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}

        override fun onActivityDestroyed(activity: Activity) {}
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "${Components.PACKAGE_NAME}/doctor")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(
            binding.binaryMessenger,
            "${Components.PACKAGE_NAME}/doctor/state",
        )
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        onCancel(null)
        resolveAll()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestVpnPermission" -> requestVpnPermission {
                result.success(it)
                publish()
            }

            "openSettings" -> {
                val action = when (call.arguments as? String) {
                    "vpn" -> Settings.ACTION_VPN_SETTINGS
                    "privateDns" -> Settings.ACTION_WIRELESS_SETTINGS
                    "dateTime" -> Settings.ACTION_DATE_SETTINGS
                    "captivePortal" -> Settings.ACTION_WIFI_SETTINGS
                    else -> {
                        result.error("invalidTarget", "Unknown settings target", call.arguments)
                        return
                    }
                }
                openSettings(action) {
                    result.success(it)
                    publish()
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        events = sink
        lastPublished = null
        publish()
        connectivityManager.registerNetworkCallback(
            NetworkRequest.Builder()
                .removeCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
                .build(),
            networkCallback,
        )
        (context.applicationContext as Application)
            .registerActivityLifecycleCallbacks(lifecycleCallbacks)
    }

    override fun onCancel(arguments: Any?) {
        events ?: return
        events = null
        lastPublished = null
        try {
            connectivityManager.unregisterNetworkCallback(networkCallback)
        } catch (_: IllegalArgumentException) {
        }
        (context.applicationContext as Application)
            .unregisterActivityLifecycleCallbacks(lifecycleCallbacks)
    }

    private fun publishLater() {
        mainHandler.post { publish() }
    }

    private fun publish() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            publishLater()
            return
        }
        val sink = events ?: return
        val state = readState()
        if (state == lastPublished) {
            return
        }
        lastPublished = state
        sink.success(state)
    }

    private fun resolveAll() {
        pendingVpn.resolve(false)
        pendingSettings.resolve(false)
    }

    private fun requestVpnPermission(callback: (Boolean) -> Unit) {
        val intent = VpnService.prepare(context)
        if (intent == null) {
            rememberGranted()
            callback(true)
            return
        }
        val activity = activityBinding?.activity
        if (activity == null) {
            callback(false)
            return
        }
        pendingVpn.replace(callback, supersededValue = false)
        try {
            @Suppress("DEPRECATION")
            activity.startActivityForResult(intent, REQUEST_VPN)
        } catch (_: ActivityNotFoundException) {
            pendingVpn.resolve(false)
        }
    }

    private fun openSettings(action: String, callback: (Boolean) -> Unit) {
        val activity = activityBinding?.activity
        if (activity == null) {
            callback(false)
            return
        }
        pendingSettings.replace(callback, supersededValue = false)
        val started = listOf(action, Settings.ACTION_SETTINGS).any {
            try {
                @Suppress("DEPRECATION")
                activity.startActivityForResult(Intent(it), REQUEST_SETTINGS)
                true
            } catch (_: ActivityNotFoundException) {
                false
            }
        }
        if (!started) {
            pendingSettings.resolve(false)
        }
    }

    private val prefs
        get() = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun rememberGranted() {
        prefs.edit().putBoolean(KEY_VPN_GRANTED, true).apply()
    }

    private fun vpnPermission(): String {
        if (VpnService.prepare(context) == null) {
            rememberGranted()
            return "granted"
        }
        return if (prefs.getBoolean(KEY_VPN_GRANTED, false)) "revoked" else "notAsked"
    }

    private fun readState(): Map<String, Any?> {
        val manager = connectivityManager
        val networks = manager.allNetworks.mapNotNull { network ->
            manager.getNetworkCapabilities(network)?.let { network to it }
        }
        val otherVpn = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && networks.any { (_, caps) ->
            caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) &&
                caps.ownerUid != Process.myUid()
        }
        val underlying = underlyingNetwork(manager, networks)
        val dns = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            underlying?.let { manager.getLinkProperties(it) }
        } else {
            null
        }
        val host = dns?.privateDnsServerName
        return mapOf(
            "vpnPermission" to vpnPermission(),
            "otherVpn" to otherVpn,
            "alwaysOnVpnApp" to alwaysOnVpnApp(),
            "privateDns" to when {
                dns == null -> null
                host != null -> "strict"
                dns.isPrivateDnsActive -> "opportunistic"
                else -> "off"
            },
            "privateDnsHost" to host,
            "captivePortal" to networks.any { (_, caps) ->
                !caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) &&
                    caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_CAPTIVE_PORTAL)
            },
        )
    }

    private fun underlyingNetwork(
        manager: ConnectivityManager,
        networks: List<Pair<Network, NetworkCapabilities>>,
    ): Network? {
        val active = manager.activeNetwork
        val activeCaps = networks.firstOrNull { it.first == active }?.second
        if (active != null && activeCaps != null &&
            !activeCaps.hasTransport(NetworkCapabilities.TRANSPORT_VPN)
        ) {
            return active
        }
        return networks
            .filter { (_, caps) ->
                caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                    !caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN)
            }
            .sortedByDescending {
                it.second.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
            }
            .firstOrNull()?.first
    }

    private fun alwaysOnVpnApp(): String? = try {
        Settings.Secure.getString(context.contentResolver, "always_on_vpn_app") ?: ""
    } catch (_: Exception) {
        null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(activityResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        detachFromActivity()
        resolveAll()
    }

    private fun detachFromActivity() {
        activityBinding?.removeActivityResultListener(activityResultListener)
        activityBinding = null
    }

    private companion object {
        // Every plugin on the activity sees every result; BatteryPlugin holds 1005.
        const val REQUEST_VPN = 1006

        const val REQUEST_SETTINGS = 1007

        const val PREFS = "doctor"

        const val KEY_VPN_GRANTED = "doctor.vpnGranted"
    }
}
