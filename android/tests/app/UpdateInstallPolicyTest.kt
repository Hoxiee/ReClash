package com.reclash.updates

import com.reclash.common.RunIntentArbiter
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class UpdateInstallPolicyTest {
    @Test
    fun `only fully stopped service permits install`() {
        assertFalse(updateInstallBlocked(runRequested = false, stopped = true, hasRuntime = false))
        assertTrue(updateInstallBlocked(runRequested = true, stopped = true, hasRuntime = false))
        assertTrue(updateInstallBlocked(runRequested = false, stopped = false, hasRuntime = false))
        assertTrue(updateInstallBlocked(runRequested = false, stopped = true, hasRuntime = true))
    }

    @Test
    fun `newer service intent invalidates installation even if stopped again`() {
        val arbiter = RunIntentArbiter()
        val captured = arbiter.current()
        assertTrue(updateInstallMayCommit(captured, arbiter.current(), false, true, false))
        arbiter.request(true)
        arbiter.request(false)
        assertFalse(updateInstallMayCommit(captured, arbiter.current(), false, true, false))
    }

    @Test
    fun `callback must match both session and its unpredictable token`() {
        assertTrue(acceptsUpdateCallback(12, "trusted", 12, "trusted"))
        assertFalse(acceptsUpdateCallback(12, "trusted", 13, "trusted"))
        assertFalse(acceptsUpdateCallback(12, "trusted", 12, "other"))
        assertFalse(acceptsUpdateCallback(12, "trusted", 12, null))
        assertFalse(acceptsUpdateCallback(-1, "trusted", -1, "trusted"))
        assertFalse(acceptsUpdateCallback(12, "", 12, ""))
    }

    @Test
    fun `recovery requires a committed session on supported Android APIs`() {
        assertTrue(updateInstallSessionRecoverable(true, true, true))
        assertTrue(updateInstallSessionRecoverable(true, false, true))
        assertFalse(updateInstallSessionRecoverable(true, false, false))
        assertFalse(updateInstallSessionRecoverable(false, false, true))
        assertFalse(updateInstallSessionRecoverable(false, true, null))
        assertFalse(updateInstallSessionRecoverable(true, true, null))
        assertTrue(updateInstallSessionRecoverable(true, false, null))
    }

    @Test
    fun `success requires an actually installed version code`() {
        assertTrue(installedUpdateMatches("v1.2.3", 10, "1.2.3", 10))
        assertTrue(installedUpdateMatches("v1.2.3", 10, "1.2.4", 11))
        assertFalse(installedUpdateMatches("v1.2.3", 10, "1.2.3", 9))
        assertFalse(installedUpdateMatches("v1.2.3", 10, "1.2.2", 10))
        assertFalse(installedUpdateMatches("v1.2.3", 10, null, 10))
        assertFalse(installedUpdateMatches("v1.2.3", 0, "1.2.3", 0))
    }
}
