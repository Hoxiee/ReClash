package com.reclash.updates

import com.reclash.common.RunIntentArbiter

internal fun updateInstallBlocked(
    runRequested: Boolean,
    stopped: Boolean,
    hasRuntime: Boolean,
): Boolean = runRequested || !stopped || hasRuntime

internal fun updateInstallMayCommit(
    captured: RunIntentArbiter.Token,
    current: RunIntentArbiter.Token,
    runRequested: Boolean,
    stopped: Boolean,
    hasRuntime: Boolean,
): Boolean = captured === current && !updateInstallBlocked(runRequested, stopped, hasRuntime)

internal fun acceptsUpdateCallback(
    expectedSession: Int,
    expectedToken: String,
    actualSession: Int,
    actualToken: String?,
): Boolean = expectedSession >= 0 && expectedSession == actualSession &&
    expectedToken.isNotEmpty() && expectedToken == actualToken

internal fun updateInstallSessionRecoverable(
    hasSession: Boolean,
    preparing: Boolean,
    sealed: Boolean?,
): Boolean = hasSession && (sealed ?: !preparing)

internal fun installedUpdateMatches(
    expectedVersion: String,
    expectedVersionCode: Long,
    actualVersion: String?,
    actualVersionCode: Long,
): Boolean = expectedVersionCode > 0 && actualVersionCode >= expectedVersionCode &&
    (actualVersionCode > expectedVersionCode ||
        actualVersion?.removePrefix("v") == expectedVersion.removePrefix("v"))
