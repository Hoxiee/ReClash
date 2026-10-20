package com.reclash.updates

import android.app.Activity
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Parcel
import android.provider.Settings
import android.util.Base64
import com.reclash.RunState
import com.reclash.ServiceController
import com.reclash.ServiceState
import com.reclash.common.GlobalState
import com.reclash.common.RunIntentArbiter
import java.security.MessageDigest
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext

private const val UPDATE_PREFERENCES = "reclash-update-installer"
private const val CALLBACK_SCHEME = "reclash-update-install"
private const val CONFIRM_INSTALL_ACTION = "android.content.pm.action.CONFIRM_INSTALL"
private const val MAX_CONFIRMATION_BYTES = 256 * 1024

enum class UpdateInstallStatus(val wireValue: String) {
    NONE("none"),
    PREPARING("preparing"),
    AWAITING_CONFIRMATION("awaitingConfirmation"),
    INSTALLING("installing"),
    SUCCESS("success"),
    FAILED("failed"),
    CANCELLED("cancelled"),
}

private data class UpdateInstallRecord(
    val status: UpdateInstallStatus,
    val session: Int,
    val token: String,
    val version: String,
    val versionCode: Long,
    val confirmation: String? = null,
)

object UpdateInstaller {
    private val lock = Mutex()
    @Volatile
    private var observer: ((UpdateInstallStatus) -> Unit)? = null

    fun observe(value: (UpdateInstallStatus) -> Unit) {
        observer = value
    }

    fun removeObserver(value: (UpdateInstallStatus) -> Unit) {
        if (observer === value) observer = null
    }

    fun blockedByVpn(): Boolean = updateInstallBlocked(
        ServiceState.isRunRequested,
        ServiceState.runState.value == RunState.STOPPED,
        ServiceController.runtime != null,
    )

    fun canRequestInstalls(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            context.packageManager.canRequestPackageInstalls()

    suspend fun openPermission(activity: Activity?): Boolean = withContext(Dispatchers.Main) {
        if (activity == null || activity.isFinishing || activity.isDestroyed) return@withContext false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return@withContext true
        activity.startActivity(
            Intent(
                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:${activity.packageName}"),
            ),
        )
        true
    }

    suspend fun verify(
        context: Context,
        path: String,
        expectedVersion: String,
        expectedSha256: String,
    ) {
        UpdateApkVerifier.verify(context, path, expectedVersion, expectedSha256)
    }

    suspend fun install(
        context: Context,
        path: String,
        version: String,
        sha256: String,
        automatic: Boolean,
    ): String = withContext(Dispatchers.IO) {
        lock.withLock {
            val captured = ServiceState.captureRequestToken()
            if (blockedByVpn()) return@withLock "vpnActive"
            if (!canRequestInstalls(context)) return@withLock "permissionRequired"
            val previous = reconcile(context)
            if (previous?.status in activeStatuses) return@withLock "started"
            val verified = UpdateApkVerifier.verify(context, path, version, sha256)
            val installer = context.packageManager.packageInstaller
            val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL).apply {
                setAppPackageName(context.packageName)
                setSize(verified.file.length())
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    setRequireUserAction(
                        if (automatic) PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED
                        else PackageInstaller.SessionParams.USER_ACTION_REQUIRED,
                    )
                }
            }
            val sessionId = installer.createSession(params)
            var record = UpdateInstallRecord(
                status = UpdateInstallStatus.PREPARING,
                session = sessionId,
                token = UUID.randomUUID().toString(),
                version = verified.version,
                versionCode = verified.versionCode,
            )
            try {
                save(context, record)
                installer.openSession(sessionId).use { session ->
                    copyVerifiedApk(session, verified, sha256)
                    val callback = callbackPendingIntent(context, record)
                    val committed = withContext(Dispatchers.Main) {
                        if (!mayCommit(captured)) return@withContext false
                        session.commit(callback.intentSender)
                        true
                    }
                    if (!committed) {
                        abandon(context, sessionId)
                        save(context, record.copy(status = UpdateInstallStatus.CANCELLED))
                        return@withLock "vpnActive"
                    }
                    record = record.copy(status = UpdateInstallStatus.INSTALLING)
                    save(context, record)
                }
                "started"
            } catch (error: Exception) {
                abandon(context, sessionId)
                save(context, record.copy(status = UpdateInstallStatus.FAILED, confirmation = null))
                throw error
            }
        }
    }

    suspend fun status(context: Context): UpdateInstallStatus = withContext(Dispatchers.IO) {
        lock.withLock { reconcile(context)?.status ?: UpdateInstallStatus.NONE }
    }

    suspend fun continueInstall(context: Context, activity: Activity?): Boolean = withContext(Dispatchers.IO) {
        lock.withLock {
            val captured = ServiceState.captureRequestToken()
            if (blockedByVpn()) return@withLock false
            val record = reconcile(context) ?: return@withLock false
            if (record.status != UpdateInstallStatus.AWAITING_CONFIRMATION) return@withLock false
            val encoded = record.confirmation ?: return@withLock false
            val confirmation = decodeConfirmation(encoded) ?: run {
                abandon(context, record.session)
                save(context, record.copy(status = UpdateInstallStatus.CANCELLED, confirmation = null))
                return@withLock false
            }
            if (confirmation.action != CONFIRM_INSTALL_ACTION ||
                confirmation.getIntExtra(PackageInstaller.EXTRA_SESSION_ID, -1) != record.session ||
                confirmation.selector != null
            ) {
                throw SecurityException("Update confirmation does not match its session")
            }
            val resolved = context.packageManager.resolveActivity(confirmation, PackageManager.MATCH_DEFAULT_ONLY)
                ?: return@withLock false
            val systemFlags = ApplicationInfo.FLAG_SYSTEM or ApplicationInfo.FLAG_UPDATED_SYSTEM_APP
            if (resolved.activityInfo.applicationInfo.flags and systemFlags == 0) {
                throw SecurityException("Update confirmation is not a system activity")
            }
            confirmation.component = ComponentName(
                resolved.activityInfo.packageName,
                resolved.activityInfo.name,
            )
            withContext(Dispatchers.Main) {
                if (activity == null || activity.isFinishing || activity.isDestroyed || !mayCommit(captured)) {
                    return@withContext false
                }
                activity.startActivity(confirmation)
                true
            }
        }
    }

    suspend fun receive(context: Context, intent: Intent) = lock.withLock {
        val data = intent.data ?: return@withLock
        if (intent.action != callbackAction(context) ||
            data.scheme != CALLBACK_SCHEME || data.authority != context.packageName ||
            data.pathSegments.size != 2
        ) {
            return@withLock
        }
        val record = read(context) ?: return@withLock
        val session = intent.getIntExtra(PackageInstaller.EXTRA_SESSION_ID, -1)
        if (data.pathSegments.first() != session.toString() ||
            !acceptsUpdateCallback(record.session, record.token, session, data.pathSegments.last()) ||
            record.status !in activeStatuses
        ) {
            return@withLock
        }
        val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, Int.MIN_VALUE)
        val next = when (status) {
            PackageInstaller.STATUS_PENDING_USER_ACTION -> {
                val encoded = runCatching {
                    confirmationFrom(intent)?.let(::encodeConfirmation)
                }.getOrNull()
                if (encoded == null) {
                    abandon(context, record.session)
                    record.copy(status = UpdateInstallStatus.FAILED, confirmation = null)
                } else {
                    record.copy(status = UpdateInstallStatus.AWAITING_CONFIRMATION, confirmation = encoded)
                }
            }
            PackageInstaller.STATUS_SUCCESS -> record.copy(
                status = if (isInstalled(context, record)) UpdateInstallStatus.SUCCESS else UpdateInstallStatus.FAILED,
                confirmation = null,
            )
            PackageInstaller.STATUS_FAILURE_ABORTED -> record.copy(
                status = UpdateInstallStatus.CANCELLED,
                confirmation = null,
            )
            else -> record.copy(status = UpdateInstallStatus.FAILED, confirmation = null)
        }
        if (next.status in terminalFailures) abandon(context, record.session)
        save(context, next)
    }

    private fun copyVerifiedApk(session: PackageInstaller.Session, verified: VerifiedUpdateApk, sha256: String) {
        val digest = MessageDigest.getInstance("SHA-256")
        val length = verified.file.length()
        var copied = 0L
        session.openWrite("base.apk", 0, length).use { output ->
            verified.file.inputStream().buffered().use { input ->
                val buffer = ByteArray(64 * 1024)
                while (true) {
                    val count = input.read(buffer)
                    if (count < 0) break
                    copied += count
                    if (copied > length) throw InvalidUpdateApkException("APK changed while staging")
                    digest.update(buffer, 0, count)
                    output.write(buffer, 0, count)
                }
            }
            session.fsync(output)
        }
        val expectedDigest = sha256.chunked(2).map { it.toInt(16).toByte() }.toByteArray()
        if (copied != length || !MessageDigest.isEqual(digest.digest(), expectedDigest)) {
            throw InvalidUpdateApkException("Staged APK SHA-256 does not match")
        }
    }

    private fun mayCommit(captured: RunIntentArbiter.Token): Boolean = updateInstallMayCommit(
        captured = captured,
        runRequested = ServiceState.isRunRequested,
        stopped = ServiceState.runState.value == RunState.STOPPED,
        hasRuntime = ServiceController.runtime != null,
        current = ServiceState.captureRequestToken(),
    )

    private fun callbackAction(context: Context) = "${context.packageName}.UPDATE_INSTALL_RESULT"

    private fun callbackPendingIntent(context: Context, record: UpdateInstallRecord): PendingIntent {
        val intent = Intent(context, UpdateInstallReceiver::class.java)
            .setAction(callbackAction(context))
            .setData(
                Uri.Builder().scheme(CALLBACK_SCHEME).authority(context.packageName)
                    .appendPath(record.session.toString()).appendPath(record.token).build(),
            )
        val mutability = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
        return PendingIntent.getBroadcast(context, record.session, intent, PendingIntent.FLAG_CANCEL_CURRENT or mutability)
    }

    private fun reconcile(context: Context): UpdateInstallRecord? {
        val record = read(context) ?: return null
        if (isInstalled(context, record)) {
            val installed = record.copy(status = UpdateInstallStatus.SUCCESS, confirmation = null)
            if (installed != record) save(context, installed)
            return installed
        }
        if (record.status in terminalFailures) return record
        val session = context.packageManager.packageInstaller.mySessions.firstOrNull { it.sessionId == record.session }
        val sealed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) session?.isSealed else null
        val recoverable = updateInstallSessionRecoverable(
            hasSession = session != null,
            preparing = record.status == UpdateInstallStatus.PREPARING,
            sealed = sealed,
        )
        val next = when {
            record.status == UpdateInstallStatus.SUCCESS || !recoverable -> {
                abandon(context, record.session)
                record.copy(status = UpdateInstallStatus.CANCELLED, confirmation = null)
            }
            record.confirmation != null -> record.copy(status = UpdateInstallStatus.AWAITING_CONFIRMATION)
            else -> record.copy(status = UpdateInstallStatus.INSTALLING)
        }
        if (next != record) save(context, next)
        return next
    }

    @Suppress("DEPRECATION")
    private fun isInstalled(context: Context, record: UpdateInstallRecord): Boolean {
        val info = context.packageManager.getPackageInfo(context.packageName, 0)
        val code = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) info.longVersionCode else info.versionCode.toLong()
        return installedUpdateMatches(record.version, record.versionCode, info.versionName, code)
    }

    private fun abandon(context: Context, session: Int) {
        runCatching { context.packageManager.packageInstaller.abandonSession(session) }
    }

    private fun read(context: Context): UpdateInstallRecord? {
        val preferences = context.getSharedPreferences(UPDATE_PREFERENCES, Context.MODE_PRIVATE)
        val status = preferences.getString("status", null)?.let { raw ->
            UpdateInstallStatus.entries.firstOrNull { it.wireValue == raw }
        } ?: return null
        val session = preferences.getInt("session", -1)
        val token = preferences.getString("token", null) ?: return null
        val version = preferences.getString("version", null) ?: return null
        val code = preferences.getLong("versionCode", 0)
        val confirmation = preferences.getString("confirmation", null)
        if (session < 0 || !Regex("^[a-f0-9-]{36}$").matches(token) ||
            version.isBlank() || version.length > 100 || code <= 0 ||
            (confirmation != null && confirmation.length > MAX_CONFIRMATION_BYTES * 2)
        ) {
            return null
        }
        return UpdateInstallRecord(status, session, token, version, code, confirmation)
    }

    private fun save(context: Context, record: UpdateInstallRecord) {
        val editor = context.getSharedPreferences(UPDATE_PREFERENCES, Context.MODE_PRIVATE).edit()
            .putString("status", record.status.wireValue).putInt("session", record.session)
            .putString("token", record.token).putString("version", record.version)
            .putLong("versionCode", record.versionCode).putString("confirmation", record.confirmation)
        if (!editor.commit()) throw IllegalStateException("Could not retain update installation state")
        runCatching { observer?.invoke(record.status) }
            .onFailure { GlobalState.log("Could not notify update installation status: $it") }
    }

    @Suppress("DEPRECATION")
    private fun confirmationFrom(intent: Intent): Intent? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
    } else {
        intent.getParcelableExtra(Intent.EXTRA_INTENT)
    }

    private fun encodeConfirmation(intent: Intent): String? {
        val parcel = Parcel.obtain()
        return try {
            intent.writeToParcel(parcel, 0)
            val bytes = parcel.marshall()
            if (bytes.size > MAX_CONFIRMATION_BYTES) null else Base64.encodeToString(bytes, Base64.NO_WRAP)
        } finally {
            parcel.recycle()
        }
    }

    private fun decodeConfirmation(encoded: String): Intent? {
        val parcel = Parcel.obtain()
        return try {
            val bytes = Base64.decode(encoded, Base64.NO_WRAP)
            if (bytes.size > MAX_CONFIRMATION_BYTES) return null
            parcel.unmarshall(bytes, 0, bytes.size)
            parcel.setDataPosition(0)
            Intent.CREATOR.createFromParcel(parcel)
        } catch (_: Exception) {
            null
        } finally {
            parcel.recycle()
        }
    }

    private val activeStatuses = setOf(
        UpdateInstallStatus.PREPARING,
        UpdateInstallStatus.INSTALLING,
        UpdateInstallStatus.AWAITING_CONFIRMATION,
    )
    private val terminalFailures = setOf(UpdateInstallStatus.FAILED, UpdateInstallStatus.CANCELLED)
}
