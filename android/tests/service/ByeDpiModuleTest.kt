package com.reclash.service.modules

import com.reclash.common.AccessControlMode
import com.reclash.service.ServiceConfig
import com.reclash.service.models.AccessControlProps
import com.reclash.service.models.VpnOptions
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
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
        var startResult = true

        override fun start(args: List<String>): Boolean {
            starts += args
            return startResult
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
    fun `one missed probe is not a dead listener`() = runTest {
        module().start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        engine.alive = false
        advanceTimeBy(ByeDpiPolicy.PROBE_INTERVAL_MS + 1)
        runCurrent()
        assertEquals(0, engine.stops)
        assertEquals(1, engine.starts.size)
    }

    @Test
    fun `consecutive missed probes restart the branch`() = runTest {
        module().start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        engine.alive = false
        advanceTimeBy(ByeDpiPolicy.PROBE_INTERVAL_MS * ByeDpiPolicy.PROBE_MISSES + 1)
        runCurrent()
        assertEquals(1, engine.stops)
        assertEquals(2, engine.starts.size)
        // The backoff only spaces the next probe, not the restart itself.
        advanceTimeBy(ByeDpiPolicy.backoffMs(0))
        runCurrent()
        assertEquals(2, engine.starts.size)
    }

    @Test
    fun `a refused start is retried with backoff`() = runTest {
        module().start()
        engine.startResult = false
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        assertEquals(1, engine.starts.size)
        engine.startResult = true
        advanceTimeBy(ByeDpiPolicy.backoffMs(0))
        runCurrent()
        assertEquals(2, engine.starts.size)
    }

    @Test
    fun `a strategy cannot retune the listener or the cache`() = runTest {
        module().start()
        ServiceConfig.updateVpnOptions(
            options(
                strategy = listOf("-d1", "-p", "9050", "-i", "0.0.0.0", "-s1"),
            ),
        )
        runCurrent()
        val args = engine.starts.single()
        assertEquals("7898", args[args.indexOf("-p") + 1])
        assertEquals("127.0.0.1", args[args.indexOf("-i") + 1])
        assertTrue("9050" !in args)
        assertTrue("0.0.0.0" !in args)
        assertTrue("-d1" in args)
        assertTrue("-s1" in args)
    }

    @Test
    fun `a testing run keeps the cache detached`() = runTest {
        val module = module()
        module.start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        assertTrue("-y" !in engine.starts.single())
        module.onEnvironmentChanged("abc123")
        runCurrent()
        assertTrue("-y" in engine.starts.last())
        ServiceConfig.updateVpnOptions(options().copy(desyncTesting = true))
        runCurrent()
        assertTrue("-y" !in engine.starts.last())
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

    @Test
    fun `an environment change after stop cannot resurrect the branch`() = runTest {
        val module = module()
        module.start()
        ServiceConfig.updateVpnOptions(options())
        runCurrent()
        module.stop()
        module.onEnvironmentChanged("abc123")
        runCurrent()
        assertEquals(1, engine.starts.size)
    }

    // The options flow and environment changes land from separate coroutines on
    // a multi-threaded dispatcher: an apply that slips past an in-flight stop
    // would start a second branch over the receiver the stop is about to close.
    @Test
    fun `an apply waits for an in-flight stop instead of racing it`() = runTest {
        val blocking = BlockingEngine()
        val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        val module = ByeDpiModule(scope, blocking) { }
        module.start()
        ServiceConfig.updateVpnOptions(options())
        assertTrue(blocking.firstStart.await(2, TimeUnit.SECONDS))

        ServiceConfig.updateVpnOptions(options(port = 7899))
        assertTrue(blocking.inStop.await(2, TimeUnit.SECONDS))
        module.onEnvironmentChanged("abc")

        val deadline = System.nanoTime() + TimeUnit.MILLISECONDS.toNanos(500)
        while (System.nanoTime() < deadline) {
            assertEquals("no start may slip past a mid-flight stop", 1, blocking.starts.get())
            Thread.sleep(20)
        }

        blocking.release()
        val settled = System.nanoTime() + TimeUnit.SECONDS.toNanos(5)
        while (blocking.starts.get() < 3 && System.nanoTime() < settled) {
            Thread.sleep(20)
        }
        assertEquals(3, blocking.starts.get())
        assertEquals(2, blocking.stops.get())

        module.stop()
        scope.cancel()
    }

    private class BlockingEngine : ByeDpiModule.Engine {
        val starts = AtomicInteger()
        val stops = AtomicInteger()
        val firstStart = CountDownLatch(1)
        val inStop = CountDownLatch(1)
        private val releaseStop = CountDownLatch(1)

        override fun start(args: List<String>): Boolean {
            starts.incrementAndGet()
            firstStart.countDown()
            return true
        }

        override fun stop() {
            stops.incrementAndGet()
            inStop.countDown()
            releaseStop.await()
        }

        fun release() = releaseStop.countDown()

        override fun probe(port: Int): Boolean = true

        override fun protectPath(): String? = "/data/byedpi.protect"

        override fun cacheFile(envKey: String): String? =
            if (envKey.isEmpty()) null else "/cache/$envKey.cache"
    }
}
