package com.reclash.service.modules

import com.reclash.common.AccessControlMode
import com.reclash.service.PauseState
import com.reclash.service.ServiceConfig
import com.reclash.service.models.AccessControlProps
import com.reclash.service.models.VpnOptions
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class SmartPauseModuleTest {

    private class FakeActions : SmartPauseModule.Actions {
        var pauseCalls = 0
        var resumeCalls = 0

        override fun pause() {
            pauseCalls++
            ServiceConfig.updatePauseState(PauseState(paused = true))
        }

        override fun resume() {
            resumeCalls++
            ServiceConfig.updatePauseState(PauseState())
        }
    }

    private lateinit var actions: FakeActions
    private val logs = mutableListOf<String>()

    private fun options(
        enabled: Boolean = true,
        networks: List<String> = listOf("192.168.1.0/24", "Home Wi-Fi"),
    ) = VpnOptions(
        enable = true,
        port = 7890,
        ipv6 = false,
        dnsHijacking = true,
        accessControlProps = AccessControlProps(
            enable = false,
            mode = AccessControlMode.ACCEPT_SELECTED,
            acceptList = emptyList(),
            rejectList = emptyList(),
        ),
        allowBypass = false,
        systemProxy = false,
        bypassDomain = emptyList(),
        stack = "system",
        routeAddress = listOf("0.0.0.0/0"),
        smartPauseEnabled = enabled,
        smartPauseNetworks = networks,
        smartPauseCloseConnections = true,
    )

    // The default log seam hits android.util.Log, which is not mocked on the JVM.
    private fun TestScope.module(uptimeMillis: () -> Long) =
        SmartPauseModule(backgroundScope, actions, uptimeMillis) { logs += it }

    @Before
    fun setUp() {
        actions = FakeActions()
        logs.clear()
        ServiceConfig.updatePauseState(PauseState())
        ServiceConfig.updateVpnOptions(options())
        ServiceConfig.updateSessionStartedAt(0L)
    }

    @After
    fun tearDown() {
        ServiceConfig.updatePauseState(PauseState())
        ServiceConfig.updateVpnOptions(options(enabled = false))
    }

    @Test
    fun `trusted network pauses after the debounce`() = runTest {
        val module = module({ 60_000L })
        module.start()
        module.onPhysicalNetworksChanged(listOf("192.168.1.55"), listOf("Other Wi-Fi"))
        advanceTimeBy(SmartPausePolicy.DECISION_DEBOUNCE_MS)
        runCurrent()
        assertEquals(1, actions.pauseCalls)
        assertTrue(ServiceConfig.pauseState.value.paused)
    }

    @Test
    fun `untrusted network never pauses`() = runTest {
        val module = module({ 60_000L })
        module.start()
        module.onPhysicalNetworksChanged(listOf("8.8.8.8"), listOf("Other Wi-Fi"))
        advanceTimeBy(60_000)
        runCurrent()
        assertEquals(0, actions.pauseCalls)
    }

    @Test
    fun `young session defers the pause until the guard passes`() = runTest {
        var clock = 1_000L
        val module = module({ clock })
        module.start()
        module.onPhysicalNetworksChanged(listOf("192.168.1.55"), emptyList())
        advanceTimeBy(SmartPausePolicy.DECISION_DEBOUNCE_MS)
        runCurrent()
        assertEquals(0, actions.pauseCalls)

        clock = SmartPausePolicy.STARTUP_GUARD_MS + 1
        advanceTimeBy(60_000)
        runCurrent()
        assertEquals(1, actions.pauseCalls)
    }

    @Test
    fun `leaving the trusted network resumes`() = runTest {
        val module = module({ 60_000L })
        module.start()
        module.onPhysicalNetworksChanged(listOf("192.168.1.55"), emptyList())
        advanceTimeBy(10_000)
        runCurrent()
        assertEquals(1, actions.pauseCalls)

        module.onPhysicalNetworksChanged(listOf("100.64.0.9"), emptyList())
        advanceTimeBy(60_000)
        runCurrent()
        assertEquals(1, actions.resumeCalls)
        assertFalse(ServiceConfig.pauseState.value.paused)
    }

    @Test
    fun `disabled config performs no transitions`() = runTest {
        ServiceConfig.updateVpnOptions(options(enabled = false))
        val module = module({ 60_000L })
        module.start()
        module.onPhysicalNetworksChanged(listOf("192.168.1.55"), emptyList())
        advanceTimeBy(60_000)
        runCurrent()
        assertEquals(0, actions.pauseCalls)
    }

    @Test
    fun `manual pause survives while the anchor network holds`() = runTest {
        val module = module({ 60_000L })
        module.start()
        module.onPhysicalNetworksChanged(listOf("192.168.1.55"), emptyList())
        advanceTimeBy(60_000)
        runCurrent()
        assertEquals(1, actions.pauseCalls)

        ServiceConfig.updatePauseState(PauseState(paused = true, manual = true))
        runCurrent()
        module.onPhysicalNetworksChanged(listOf("192.168.1.55"), emptyList())
        advanceTimeBy(60_000)
        runCurrent()
        assertEquals(0, actions.resumeCalls)
        assertTrue(ServiceConfig.pauseState.value.paused)
    }

    @Test
    fun `manual pause resumes when the anchor network is left`() = runTest {
        val module = module({ 60_000L })
        module.start()
        module.onPhysicalNetworksChanged(listOf("192.168.1.55"), emptyList())
        advanceTimeBy(60_000)
        runCurrent()
        ServiceConfig.updatePauseState(PauseState(paused = true, manual = true))
        runCurrent()

        module.onPhysicalNetworksChanged(listOf("8.8.8.8"), emptyList())
        advanceTimeBy(60_000)
        runCurrent()
        assertEquals(1, actions.resumeCalls)
        assertFalse(ServiceConfig.pauseState.value.paused)
    }

    @Test
    fun `manual pause converts to policy pause on another trusted network`() = runTest {
        val module = module({ 60_000L })
        module.start()
        module.onPhysicalNetworksChanged(listOf("192.168.1.55"), emptyList())
        advanceTimeBy(60_000)
        runCurrent()
        ServiceConfig.updatePauseState(PauseState(paused = true, manual = true))
        runCurrent()

        module.onPhysicalNetworksChanged(listOf("10.0.0.2"), listOf("Home Wi-Fi"))
        advanceTimeBy(60_000)
        runCurrent()
        assertEquals(0, actions.resumeCalls)
        assertTrue(ServiceConfig.pauseState.value.paused)
        assertFalse(ServiceConfig.pauseState.value.manual)
    }

    @Test
    fun `unknown network does not act`() = runTest {
        val module = module({ 60_000L })
        module.start()
        module.onPhysicalNetworksChanged(emptyList(), emptyList())
        advanceTimeBy(60_000)
        runCurrent()
        assertEquals(0, actions.pauseCalls)
        assertEquals(0, actions.resumeCalls)
    }
}
