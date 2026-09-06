package com.reclash.service

import android.app.Service
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import com.reclash.byedpi.ByeDpiNative
import com.reclash.common.GlobalState
import com.reclash.service.modules.BYEDPI_LOOPBACK
import com.reclash.service.modules.ByeDpiModule
import java.io.File
import java.net.Inet4Address
import java.net.InetSocketAddress
import java.net.Socket
import kotlin.concurrent.thread

internal class ByeDpiRuntime(
    private val service: Service,
    private val protect: ((Int) -> Boolean)?,
    private val log: (String) -> Unit = GlobalState::log,
) : ByeDpiModule.Engine {
    @Volatile private var branch: Thread? = null
    private var receiver: ByeDpiProtect? = null
    private var receiverThread: Thread? = null

    // False means the engine is not running these args: either the old
    // branch refused to drain, or the branch died on launch.
    @Synchronized override fun start(args: List<String>): Boolean {
        branch?.join(BRANCH_DRAIN_MS)
        if (branch?.isAlive == true) {
            log("Desync branch still draining, keeping the previous run")
            return false
        }
        openReceiver()
        val dns = underlyingDns()
        log("Desync engine dns: ${dns ?: "system"}")
        ByeDpiNative.setDns(dns)
        branch = thread(name = THREAD_NAME) {
            try {
                val status = runCatching { ByeDpiNative.runUntilStopped(args) }
                    .getOrElse { error ->
                        log("Desync branch crashed: $error")
                        -1
                    }
                if (status != 0) log("Desync branch exited with $status")
            } finally {
                branch = null
            }
        }
        return branch != null
    }

    @Synchronized override fun stop() {
        val running = branch
        if (running != null) {
            ByeDpiNative.stop()
            running.join(STOP_JOIN_MS)
            if (running.isAlive) {
                // Forcing fds closed now would strand the live engine (fdsan).
                log("Desync branch did not stop, leaving it to wind down")
                return
            }
        }
        closeReceiver()
    }

    override fun probe(port: Int): Boolean = runCatching {
        Socket().use { socket ->
            socket.tcpNoDelay = true
            socket.connect(InetSocketAddress(BYEDPI_LOOPBACK, port), PROBE_TIMEOUT_MS)
            socket.soTimeout = PROBE_TIMEOUT_MS
            socket.getOutputStream().write(byteArrayOf(5, 1, 0))
            socket.getInputStream().read() == 5
        }
    }.getOrDefault(false)

    // The engine's host lookups must not go through the tunnel: the VPN's own
    // DNS answers for the whole device. Hand it the underlying link's resolver.
    private fun underlyingDns(): String? = runCatching {
        val manager = service.getSystemService(ConnectivityManager::class.java)
        for (network in manager?.allNetworks.orEmpty()) {
            val capabilities = manager?.getNetworkCapabilities(network) ?: continue
            if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) continue
            val dns = manager.getLinkProperties(network)?.dnsServers
                ?.firstOrNull { it is Inet4Address } ?: continue
            return dns.hostAddress
        }
        null
    }.getOrNull()

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
        const val BRANCH_DRAIN_MS = 8_000L
        const val PROBE_TIMEOUT_MS = 1_500
    }
}
