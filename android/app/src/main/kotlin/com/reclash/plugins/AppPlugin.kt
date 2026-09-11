package com.reclash.plugins

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.app.ActivityManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.getSystemService
import androidx.core.content.FileProvider
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import androidx.core.net.toUri
import com.reclash.R
import com.reclash.common.Components
import com.reclash.common.GlobalState
import com.reclash.common.PendingCallback
import com.reclash.common.QuickAction
import com.reclash.common.quickIntent
import com.reclash.common.registerReceiverCompat
import com.reclash.getPackageIconPath
import com.reclash.packages.PackageResolver
import com.reclash.SUBSCRIPTION_NOTICE_CHANNEL
import com.reclash.isChannelEnabled
import com.reclash.showNotice
import com.reclash.showToast
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.io.File

class AppPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private var activity: Activity? = null

    private var activityBinding: ActivityPluginBinding? = null

    private val activityResultListener =
        PluginRegistry.ActivityResultListener(::onActivityResult)

    private val permissionsResultListener =
        PluginRegistry.RequestPermissionsResultListener(::onRequestPermissionsResultListener)

    private lateinit var channel: MethodChannel

    private lateinit var scope: CoroutineScope

    private val vpnPrepareCallback = PendingCallback<Boolean>()

    private val requestNotificationCallback = PendingCallback<Boolean>()

    private val requestInstalledAppsCallback = PendingCallback<Boolean>()

    private var isRequestingNotificationPermission = false

    private val gson = Gson()

    private val packageResolver by lazy {
        PackageResolver(
            GlobalState.application.packageManager,
            GlobalState.application.packageName,
        )
    }

    private var packageChangeContext: Context? = null

    private val packageChangeReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent == null || intent.data?.schemeSpecificPart == GlobalState.application.packageName) {
                return
            }
            val addedByUpdate = intent.action == Intent.ACTION_PACKAGE_ADDED &&
                intent.getBooleanExtra(Intent.EXTRA_REPLACING, false)
            if (addedByUpdate) {
                return
            }
            packageResolver.invalidate()
            channel.invokeMethod("packagesChanged", null)
        }
    }

    private var skipNotificationPermissionRequest = false

    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * The permission and consent hops below touch the Activity — starting an
     * activity for result, raising a permission prompt — and read the state that
     * tracks whether one is already up. Their callers are coroutines on
     * [Dispatchers.Default], while the answers come back on the main thread
     * through the ActivityAware listeners, so main is the one thread both ends
     * can agree on. A plain main-looper post rather than the plugin scope: the
     * scope is cancelled when the engine detaches, and a request dropped there
     * would leave its caller waiting for a callback that can no longer run.
     */
    private fun onMainThread(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post(block)
        }
    }

    override fun onMethodCall(call: MethodCall, rawResult: Result) {
        val result = MainThreadResult(rawResult)
        when (call.method) {
            "moveTaskToBack" -> {
                activity?.moveTaskToBack(true)
                result.success(true)
            }

            "setIconVariant" -> {
                val variant = call.arguments as? String
                if (variant == null) {
                    result.error("INVALID_ARGUMENT", "Icon variant must be a string", null)
                } else {
                    reply(result) {
                        setIconVariant(variant)
                        true
                    }
                }
            }

            "updateExcludeFromRecents" -> {
                val value = call.argument<Boolean>("value")
                updateExcludeFromRecents(value)
                result.success(true)
            }

            "initShortcuts" -> {
                val label = call.arguments as? String
                if (label == null) {
                    result.error("INVALID_ARGUMENT", "Shortcut label must be a string", null)
                } else {
                    initShortcuts(label)
                    result.success(true)
                }
            }

            "getPackages" -> reply(result) {
                gson.toJson(packageResolver.installedPackages)
            }

            "getChinaPackageNames" -> reply(result) {
                gson.toJson(packageResolver.getChinaPackageNames())
            }

            "isInstalledAppsPermissionGranted" -> reply(result) {
                packageResolver.hasInstalledAppsPermission()
            }

            "isNotificationsPermissionGranted" -> {
                result.success(isNotificationsPermissionGranted())
            }

            "getNotificationStatus" -> {
                result.success(notificationStatus(call.argument("serviceChannelId")))
            }

            "openNotificationSettings" -> {
                result.success(openNotificationSettings(call.argument("channelId")))
            }

            "requestNotificationsPermission" -> {
                requestNotificationPermission { result.success(it) }
            }

            "requestInstalledAppsPermission" -> {
                requestInstalledAppsPermission { granted -> result.success(granted) }
            }

            "getPackageIcon" -> {
                handleGetPackageIcon(call, result)
            }

            "tip" -> {
                val message = call.argument<String>("message")
                GlobalState.application.showToast(message)
                result.success(true)
            }

            "isBatteryOptimizationDisabled" -> {
                result.success(isBatteryOptimizationDisabled())
            }

            "openBatteryOptimizationSettings" -> {
                result.success(openBatteryOptimizationSettings())
            }

            "openAppSettings" -> {
                result.success(openAppSettings())
            }

            "didCrashOnPreviousExecution" -> reply(result) {
                GlobalState.didCrashOnPreviousExecution()
            }

            "getLastExitInfo" -> reply(result) {
                GlobalState.lastExitInfo()
            }

            "canRequestPackageInstalls" -> {
                result.success(canRequestPackageInstalls())
            }

            "installApk" -> {
                val path = call.argument<String>("path")
                if (path.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "APK path must be a non-empty string", null)
                } else {
                    result.success(installApk(path))
                }
            }

            "showNotice" -> reply(result) {
                GlobalState.application.showNotice(
                    channelName = call.argument<String>("channelName").orEmpty(),
                    notificationKey = call.argument<String>("notificationKey").orEmpty(),
                    title = call.argument<String>("title").orEmpty(),
                    message = call.argument<String>("message").orEmpty(),
                    actionLabel = call.argument<String>("actionLabel"),
                    actionUrl = call.argument<String>("actionUrl"),
                )
            }

            "getAndroidId" -> reply(result) {
                Settings.Secure.getString(
                    GlobalState.application.contentResolver,
                    Settings.Secure.ANDROID_ID,
                )
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleGetPackageIcon(call: MethodCall, result: Result) = reply(result) {
        val packageName = call.argument<String>("packageName") ?: ""
        GlobalState.application.packageManager.getPackageIconPath(packageName)
    }

    // A throw inside the plugin scope has no handler and ends the process;
    // the Dart caller gets a PlatformException to handle instead.
    private fun reply(result: Result, block: suspend () -> Any?) {
        scope.launch(Dispatchers.IO) {
            try {
                result.success(block())
            } catch (error: Exception) {
                GlobalState.log("Platform call failed: $error")
                result.error("PLATFORM_ERROR", error.toString(), null)
            }
        }
    }

    private fun setIconVariant(variant: String) {
        val manager = GlobalState.application.packageManager
        val targetSuffix = LauncherIconAliases.targetFor(variant) ?: return
        val components = aliasComponents()
        val target = components[targetSuffix] ?: return
        val stale = LauncherIconAliases.aliasesToDisable(variant)
            .mapNotNull(components::get)
            .filter { isAliasEnabled(manager, it) }
        val enableTarget = !isAliasEnabled(manager, target)
        if (!enableTarget && stale.isEmpty()) {
            return
        }
        // A single batched change reaches the launcher as one package update,
        // so it never has a moment with two enabled entries to draw.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            manager.setComponentEnabledSettings(
                buildList {
                    if (enableTarget) {
                        add(
                            PackageManager.ComponentEnabledSetting(
                                target,
                                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                                PackageManager.DONT_KILL_APP,
                            ),
                        )
                    }
                    for (component in stale) {
                        add(
                            PackageManager.ComponentEnabledSetting(
                                component,
                                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                                PackageManager.DONT_KILL_APP,
                            ),
                        )
                    }
                },
            )
            return
        }
        // Enabling first keeps a launcher entry alive throughout the swap.
        if (enableTarget) {
            manager.setComponentEnabledSetting(
                target,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
        for (component in stale) {
            manager.setComponentEnabledSetting(
                component,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }

    // Only the manifest default alias ships enabled, so an untouched component
    // reports DEFAULT rather than ENABLED.
    private fun isAliasEnabled(manager: PackageManager, component: ComponentName): Boolean =
        when (manager.getComponentEnabledSetting(component)) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            PackageManager.COMPONENT_ENABLED_STATE_DEFAULT ->
                component.className.endsWith(LauncherIconAliases.defaultAlias)

            else -> false
        }

    // The aliases are declared under the manifest package, which the debug
    // applicationId suffix does not carry, so they resolve by suffix match.
    private fun aliasComponents(): Map<String, ComponentName> {
        val packageName = GlobalState.application.packageName
        val activities = GlobalState.application.packageManager.getPackageInfo(
            packageName,
            PackageManager.GET_ACTIVITIES or PackageManager.GET_DISABLED_COMPONENTS,
        ).activities ?: return emptyMap()
        return LauncherIconAliases.allAliases.mapNotNull { suffix ->
            activities.firstOrNull { it.name.endsWith(suffix) }
                ?.let { suffix to ComponentName(packageName, it.name) }
        }.toMap()
    }

    private fun initShortcuts(label: String) {
        val shortcut = with(ShortcutInfoCompat.Builder(GlobalState.application, "toggle")) {
            setShortLabel(label)
            setIcon(
                IconCompat.createWithResource(
                    GlobalState.application,
                    R.mipmap.ic_launcher,
                ),
            )
            setIntent(QuickAction.TOGGLE.quickIntent)
            build()
        }
        ShortcutManagerCompat.setDynamicShortcuts(
            GlobalState.application,
            listOf(shortcut),
        )
    }

    private fun isBatteryOptimizationDisabled(): Boolean {
        val powerManager = getSystemService(GlobalState.application, PowerManager::class.java)
        return powerManager?.isIgnoringBatteryOptimizations(GlobalState.application.packageName)
            ?: false
    }

    @SuppressLint("BatteryLife")
    private fun openBatteryOptimizationSettings(): Boolean {
        // VPN continuity is the user-requested core function, so the direct exemption is intentional.
        val activity = activity ?: return false
        return try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = "package:${GlobalState.application.packageName}".toUri()
            }
            activity.startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openAppSettings(): Boolean {
        val activity = activity ?: return false
        return try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = "package:${GlobalState.application.packageName}".toUri()
            }
            activity.startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    // Below Android 8 unknown sources is one global setting, so per-app consent
    // does not exist and the install intent is always allowed to fire.
    private fun canRequestPackageInstalls(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return true
        return GlobalState.application.packageManager.canRequestPackageInstalls()
    }

    // Returns false after sending the user to the unknown-sources grant screen:
    // the caller keeps the downloaded APK and retries once the app resumes.
    private fun installApk(path: String): Boolean {
        val context = GlobalState.application
        return try {
            if (!canRequestPackageInstalls()) {
                val intent = Intent(
                    Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                    "package:${context.packageName}".toUri(),
                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                (activity ?: context).startActivity(intent)
                return false
            }
            val uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileProvider",
                File(path),
            )
            val intent = Intent(Intent.ACTION_VIEW)
                .setDataAndType(uri, APK_MIME_TYPE)
                .addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK,
                )
            // FLAG_GRANT_READ_URI_PERMISSION alone is honored from API 24 on; the
            // explicit grants keep older installers able to read the file.
            for (info in context.packageManager.queryIntentActivities(
                intent,
                PackageManager.MATCH_DEFAULT_ONLY,
            )) {
                context.grantUriPermission(
                    info.activityInfo.packageName,
                    uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION,
                )
            }
            (activity ?: context).startActivity(intent)
            true
        } catch (error: Exception) {
            GlobalState.log("installApk failed: $error")
            false
        }
    }

    @Suppress("DEPRECATION")
    private fun updateExcludeFromRecents(value: Boolean?) {
        val am = getSystemService(GlobalState.application, ActivityManager::class.java)
        val task = am?.appTasks?.firstOrNull {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                it.taskInfo.taskId == activity?.taskId
            } else {
                it.taskInfo.id == activity?.taskId
            }
        }
        task?.setExcludeFromRecents(value ?: false)
    }

    private fun notificationStatus(serviceChannelId: String?): Map<String, Boolean> {
        val context = GlobalState.application
        val channelId = serviceChannelId?.takeIf(String::isNotBlank)
            ?: GlobalState.NOTIFICATION_CHANNEL
        return mapOf(
            "permissionGranted" to isNotificationsPermissionGranted(),
            "serviceChannelEnabled" to context.isChannelEnabled(channelId),
            "subscriptionChannelEnabled" to context.isChannelEnabled(SUBSCRIPTION_NOTICE_CHANNEL),
        )
    }

    private fun openNotificationSettings(channelId: String?): Boolean {
        val activity = activity ?: return false
        return try {
            val intent = if (
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                !channelId.isNullOrBlank()
            ) {
                Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, GlobalState.application.packageName)
                    putExtra(Settings.EXTRA_CHANNEL_ID, channelId)
                }
            } else {
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, GlobalState.application.packageName)
                }
            }
            activity.startActivity(intent)
            true
        } catch (_: Exception) {
            openAppSettings()
        }
    }

    private fun isNotificationsPermissionGranted(): Boolean {
        val context = GlobalState.application
        val enabled = NotificationManagerCompat.from(context).areNotificationsEnabled()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return enabled
        return enabled && ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.POST_NOTIFICATIONS,
        ) == PackageManager.PERMISSION_GRANTED
    }

    fun requestNotificationPermission(callback: (Boolean) -> Unit) = onMainThread {
        requestNotificationCallback.replace(callback, supersededValue = false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val permission = ContextCompat.checkSelfPermission(
                GlobalState.application,
                Manifest.permission.POST_NOTIFICATIONS,
            )
            if (permission == PackageManager.PERMISSION_GRANTED || skipNotificationPermissionRequest) {
                invokeRequestNotificationCallback(true)
                return@onMainThread
            }
            if (isRequestingNotificationPermission) {
                return@onMainThread
            }
            isRequestingNotificationPermission = true
            activity?.let {
                ActivityCompat.requestPermissions(
                    it,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_REQUEST_CODE,
                )
            } ?: invokeRequestNotificationCallback(true)
            return@onMainThread
        }
        invokeRequestNotificationCallback(true)
    }

    private fun invokeRequestNotificationCallback(shouldStart: Boolean) {
        isRequestingNotificationPermission = false
        requestNotificationCallback.resolve(shouldStart)
    }

    private fun requestInstalledAppsPermission(callback: (Boolean) -> Unit) = onMainThread {
        requestInstalledAppsCallback.replace(callback, supersededValue = false)
        val activity = activity
        if (packageResolver.hasInstalledAppsPermission()) {
            invokeRequestInstalledAppsCallback(true)
            return@onMainThread
        }
        if (activity == null) {
            invokeRequestInstalledAppsCallback(false)
            return@onMainThread
        }
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(PackageResolver.GET_INSTALLED_APPS),
            INSTALLED_APPS_PERMISSION_REQUEST_CODE,
        )
    }

    private fun invokeRequestInstalledAppsCallback(granted: Boolean) {
        if (granted) {
            packageResolver.invalidate()
        }
        requestInstalledAppsCallback.resolve(granted)
    }

    fun prepareVpn(needPrepare: Boolean, callback: (Boolean) -> Unit) = onMainThread {
        vpnPrepareCallback.replace(callback, supersededValue = false)
        if (!needPrepare) {
            invokeVpnPrepareCallback(true)
            return@onMainThread
        }
        val intent = VpnService.prepare(GlobalState.application)
        if (intent != null) {
            val activity = activity
            if (activity == null) {
                invokeVpnPrepareCallback(false)
            } else {
                @Suppress("DEPRECATION")
                activity.startActivityForResult(intent, VPN_PERMISSION_REQUEST_CODE)
            }
            return@onMainThread
        }
        invokeVpnPrepareCallback(true)
    }

    // Posted rather than run where the cancellation lands, so it stays ordered
    // behind the prepareVpn that installed the callback it is cancelling.
    fun cancelVpnPreparation(callback: (Boolean) -> Unit) = onMainThread {
        vpnPrepareCallback.cancel(callback)
    }

    private fun invokeVpnPrepareCallback(granted: Boolean) {
        vpnPrepareCallback.resolve(granted)
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "${Components.PACKAGE_NAME}/app")
        channel.setMethodCallHandler(this)
        watchPackageChanges(flutterPluginBinding.applicationContext)
    }

    private fun watchPackageChanges(context: Context) {
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REPLACED)
            addAction(Intent.ACTION_PACKAGE_FULLY_REMOVED)
            addDataScheme("package")
        }
        context.registerReceiverCompat(packageChangeReceiver, filter)
        packageChangeContext = context
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        packageChangeContext?.unregisterReceiver(packageChangeReceiver)
        packageChangeContext = null
        channel.setMethodCallHandler(null)
        scope.cancel()
        invokeVpnPrepareCallback(false)
        invokeRequestNotificationCallback(false)
        invokeRequestInstalledAppsCallback(false)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachToActivity(binding)
    }

    private fun attachToActivity(binding: ActivityPluginBinding) {
        detachFromActivity()
        activityBinding = binding
        activity = binding.activity
        binding.addActivityResultListener(activityResultListener)
        binding.addRequestPermissionsResultListener(permissionsResultListener)
    }

    private fun detachFromActivity() {
        activity = null
        val binding = activityBinding ?: return
        activityBinding = null
        binding.removeActivityResultListener(activityResultListener)
        binding.removeRequestPermissionsResultListener(permissionsResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attachToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        channel.invokeMethod("exit", null)
        detachFromActivity()
        invokeVpnPrepareCallback(false)
        invokeRequestNotificationCallback(false)
        invokeRequestInstalledAppsCallback(false)
    }

    private fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != VPN_PERMISSION_REQUEST_CODE) {
            return false
        }
        invokeVpnPrepareCallback(resultCode == Activity.RESULT_OK)
        return true
    }

    private fun onRequestPermissionsResultListener(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ): Boolean = when (requestCode) {
        NOTIFICATION_PERMISSION_REQUEST_CODE -> {
            skipNotificationPermissionRequest = true
            invokeRequestNotificationCallback(true)
            true
        }

        INSTALLED_APPS_PERMISSION_REQUEST_CODE -> {
            invokeRequestInstalledAppsCallback(
                grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED,
            )
            true
        }

        else -> false
    }

    private companion object {
        const val VPN_PERMISSION_REQUEST_CODE = 1001
        const val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002
        const val INSTALLED_APPS_PERMISSION_REQUEST_CODE = 1003
        const val APK_MIME_TYPE = "application/vnd.android.package-archive"
    }
}
