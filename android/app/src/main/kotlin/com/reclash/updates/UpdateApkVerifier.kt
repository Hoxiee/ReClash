package com.reclash.updates

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.io.File
import java.security.MessageDigest
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class InvalidUpdateApkException(message: String) : Exception(message)

internal data class VerifiedUpdateApk(
    val file: File,
    val version: String,
    val versionCode: Long,
)

internal object UpdateApkVerifier {
    private val fileName = Regex("^update-[A-Za-z0-9._-]+\\.apk$")
    private val digestPattern = Regex("^[0-9a-fA-F]{64}$")

    @Suppress("DEPRECATION")
    suspend fun verify(
        context: Context,
        path: String,
        expectedVersion: String,
        expectedSha256: String,
    ): VerifiedUpdateApk = withContext(Dispatchers.IO) {
        val directory = File(context.filesDir, "app-updates").canonicalFile
        val file = File(path).canonicalFile
        if (file.parentFile != directory || !file.isFile || !fileName.matches(file.name)) {
            throw InvalidUpdateApkException("APK path is outside the update directory")
        }
        if (!digestPattern.matches(expectedSha256)) {
            throw InvalidUpdateApkException("APK SHA-256 is invalid")
        }
        val digest = MessageDigest.getInstance("SHA-256")
        file.inputStream().buffered().use { input ->
            val buffer = ByteArray(64 * 1024)
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                digest.update(buffer, 0, count)
            }
        }
        val expectedDigest = expectedSha256.chunked(2).map { it.toInt(16).toByte() }.toByteArray()
        if (!MessageDigest.isEqual(digest.digest(), expectedDigest)) {
            throw InvalidUpdateApkException("APK SHA-256 does not match")
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            PackageManager.GET_SIGNING_CERTIFICATES
        } else {
            PackageManager.GET_SIGNATURES
        }
        val update = context.packageManager.getPackageArchiveInfo(file.path, flags)
            ?: throw InvalidUpdateApkException("APK metadata is invalid")
        val installed = context.packageManager.getPackageInfo(context.packageName, flags)
        val updateCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            update.longVersionCode
        } else {
            update.versionCode.toLong()
        }
        val installedCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            installed.longVersionCode
        } else {
            installed.versionCode.toLong()
        }
        if (update.packageName != context.packageName ||
            expectedVersion.isBlank() ||
            update.versionName?.removePrefix("v") != expectedVersion.removePrefix("v") ||
            updateCode <= installedCode
        ) {
            throw InvalidUpdateApkException("APK package identity or version does not match")
        }
        val trusted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val updateSigning = update.signingInfo
                ?: throw InvalidUpdateApkException("APK signing metadata is missing")
            val installedSigning = installed.signingInfo
                ?: throw InvalidUpdateApkException("Installed signing metadata is missing")
            val updateSigners = updateSigning.apkContentsSigners.map { it.toCharsString() }.toSet()
            val installedSigners = installedSigning.apkContentsSigners.map { it.toCharsString() }.toSet()
            if (updateSigners.isEmpty() || installedSigners.isEmpty()) {
                false
            } else if (updateSigning.hasMultipleSigners() || installedSigning.hasMultipleSigners()) {
                updateSigners == installedSigners
            } else {
                val history = updateSigning.signingCertificateHistory
                    ?.map { it.toCharsString() }?.toSet().orEmpty()
                history.containsAll(installedSigners)
            }
        } else {
            val updateSigners = update.signatures?.map { it.toCharsString() }?.toSet().orEmpty()
            val installedSigners = installed.signatures?.map { it.toCharsString() }?.toSet().orEmpty()
            installedSigners.isNotEmpty() && updateSigners == installedSigners
        }
        if (!trusted) throw InvalidUpdateApkException("APK signing certificate does not match")
        VerifiedUpdateApk(file, expectedVersion, updateCode)
    }
}
