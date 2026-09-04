package com.reclash.service

import android.app.Service
import com.reclash.byedpi.ByeDpiNative
import com.reclash.common.GlobalState
import com.reclash.service.modules.BYEDPI_LOOPBACK
import com.reclash.service.modules.ByeDpiModule
import java.io.File
import java.net.InetSocketAddress
import java.net.Socket
import kotlin.concurrent.thread

internal class ByeDpiRuntime(
    private val service: Service,
    private val protect: ((Int) -> Boolean)?,
    private val log: (String) -> Unit = GlobalState::log,
) : ByeDpiModule.Engine {
    private var branch: Thread? = null
    private var receiver: ByeDpiProtect? = null
    private var receiverThread: Thread? = null

    override fun start(args: List<String>) {
        if (branch != null) return
        openReceiver()
        branch = thread(name = THREAD_NAME) {
            val status = runCatching { ByeDpiNative.runUntilStopped(args) }
                .getOrElse { error ->
                    log("Desync branch crashed: $error")
                    -1
                }
            if (status != 0) log("Desync branch exited with $status")
        }
    }

    override fun stop() {
        val running = branch ?: return
        branch = null
        ByeDpiNative.stop()
        running.join(STOP_JOIN_MS)
        if (running.isAlive) {
            log("Desync branch did not stop, closing the listener")
            ByeDpiNative.forceClose()
            running.join(STOP_JOIN_MS)
        }
        closeReceiver()
    }

    override fun probe(port: Int): Boolean = runCatching {
        Socket().use { socket ->
            socket.connect(InetSocketAddress(BYEDPI_LOOPBACK, port), PROBE_TIMEOUT_MS)
        }
        true
    }.getOrDefault(false)

    override fun protectPath(): String? =
        if (protect == null) null else File(service.filesDir, PROTECT_SOCKET).path

    // An unknown environment gets no cache file at all: sharing one across links is what
    // the per-link key exists to prevent.
    override fun cacheFile(envKey: String): String? {
        if (envKey.isEmpty()) return null
        val directory = File(service.filesDir, CACHE_DIR)
        if (!directory.isDirectory && !directory.mkdirs()) return null
        return File(directory, "$envKey.cache").path
    }

    private fun openReceiver() {
        val protectFd = protect ?: return
        if (receiver != null) return
        val next = ByeDpiProtect(File(service.filesDir, PROTECT_SOCKET), protectFd, log)
        val listener = runCatching { next.open() }.getOrElse { error ->
            log("Desync protect socket failed: $error")
            return
        }
        receiver = next
        receiverThread = thread(name = RECEIVER_THREAD_NAME) { next.acceptLoop(listener) }
    }

    private fun closeReceiver() {
        receiver?.close()
        receiver = null
        receiverThread?.join(STOP_JOIN_MS)
        receiverThread = null
    }

    private companion object {
        const val THREAD_NAME = "byedpi"
        const val RECEIVER_THREAD_NAME = "byedpi-protect"
        const val PROTECT_SOCKET = "byedpi.protect"
        const val CACHE_DIR = "byedpi"
        const val STOP_JOIN_MS = 2_000L
        const val PROBE_TIMEOUT_MS = 1_500
    }
}
