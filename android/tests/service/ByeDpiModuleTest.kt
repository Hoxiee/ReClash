package com.reclash.service.modules

import com.reclash.common.AccessControlMode
import com.reclash.service.ServiceConfig
import com.reclash.service.models.AccessControlProps
import com.reclash.service.models.VpnOptions
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class ByeDpiModuleTest {

    private class FakeEngine : ByeDpiModule.Engine {
        val starts = mutableListOf<List<String>>()
        var stops = 0
        var alive = true
        var protect: String? = "/data/byedpi.protect"

        override fun start(args: List<String>) {
            starts += args
        }

        override fun stop() {
            stops++
        }

        override fun probe(port: Int): Boolean = alive

        override fun protectPath(): String? = protect

        override fun cacheFile(envKey: String): String? =
            if (envKey.isEmpty()) null else "/cache/$envKey.cache"
    }

    private lateinit var engine: FakeEngine
    private val logs = mutableListOf<String>()

    private fun options(
        enabled: Boolean = true,
        port: Int = 7898,
        strategy: List<String> = emptyList(),
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
        desyncEnabled = enabled,
        desyncPort = port,
        desyncStrategy = strategy,
    )

    // The default log seam hits android.util.Log, which is not mocked on the JVM.
    private fun TestScope.module() = ByeDpiModule(backgroundScope, engine) { logs += it }

    @Before
    fun setUp() {
        engine = FakeEngine()
        logs.clear()
        ServiceConfig.updateVpnOptions(options(enabled = false))
    }

    @After
    fun tearDown() {
        ServiceConfig.updateVpnOptions(options(enabled = false))
    }

    @Test
    fun `the branch stays absent while the feature is off`() = runTest {
        module().start()
        advanceTimeBy(ByeDpiPolicy.PROBE_INTERVAL_MS * 3)
        runCurrent()
        assertTrue(engine.starts.isEmpty())
    }

    @Test
    fun `enabling starts the branch on the configured port`() = runTest {
        module().start()
        ServiceConfig.updateVpnOptions(options(port = 7899))
        runCurrent()
        assertEquals(1, engine.starts.size)
        val args = engine.starts.single()
        assertEquals("7899", args[args.indexOf("-p") + 1])
        assertEquals("/data/byedpi.protect", args[args.indexOf("-P") + 1])
    }

    @Test
    fun `the proxy service gets no protect path`() = runTest {
        engine.protect = null
        module().start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        assertTrue("-P" !in engine.starts.single())
    }

    @Test
    fun `disabling stops the branch`() = runTest {
        module().start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        ServiceConfig.updateVpnOptions(options(enabled = false))
        runCurrent()
        assertEquals(1, engine.stops)
    }

    @Test
    fun `a dead listener is restarted after the backoff`() = runTest {
        module().start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        engine.alive = false
        advanceTimeBy(ByeDpiPolicy.PROBE_INTERVAL_MS + 1)
        runCurrent()
        assertEquals(1, engine.stops)
        assertEquals(1, engine.starts.size)
        advanceTimeBy(ByeDpiPolicy.backoffMs(0))
        runCurrent()
        assertEquals(2, engine.starts.size)
    }

    @Test
    fun `a live listener is left alone`() = runTest {
        module().start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        advanceTimeBy(ByeDpiPolicy.PROBE_INTERVAL_MS * 4)
        runCurrent()
        assertEquals(0, engine.stops)
        assertEquals(1, engine.starts.size)
    }

    @Test
    fun `a new link restarts the branch with its own cache file`() = runTest {
        val module = module()
        module.start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        assertTrue("-y" !in engine.starts.single())

        module.onEnvironmentChanged("abc123")
        runCurrent()
        assertEquals(1, engine.stops)
        assertEquals(2, engine.starts.size)
        val args = engine.starts.last()
        assertEquals("/cache/abc123.cache", args[args.indexOf("-y") + 1])
    }

    @Test
    fun `a strategy change restarts the branch with the new args`() = runTest {
        module().start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        ServiceConfig.updateVpnOptions(options(strategy = listOf("--split", "1")))
        runCurrent()
        assertEquals(1, engine.stops)
        assertEquals(2, engine.starts.size)
        assertTrue("--split" in engine.starts.last())
    }

    @Test
    fun `stopping the module stops the branch`() = runTest {
        val module = module()
        module.start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        module.stop()
        assertEquals(1, engine.stops)
    }
}
