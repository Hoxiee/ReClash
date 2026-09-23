package com.reclash.companion

import android.content.Context
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.net.wifi.WifiManager
import java.net.Inet4Address
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference

// mDNS/NSD so a paired peer survives a DHCP lease change or an ephemeral-port restart without a
// re-scan: the receiver advertises its deviceId and the client re-resolves host:port on the first
// failed dial. Best-effort — a QR re-pair stays the ultimate fallback when multicast is filtered.
internal const val COMPANION_SERVICE_TYPE = "_reclash-cpn._tcp"

// At found-time only the name is known (attrId null) → name carries the deviceId; after resolve the
// TXT id confirms it when the responder populated attributes at all.
internal fun companionServiceMatches(serviceName: String?, attrId: String?, deviceId: String): Boolean {
    if (attrId != null) return attrId == deviceId
    return serviceName != null && serviceName.contains(deviceId)
}

internal data class CompanionEndpointAddress(val host: String, val port: Int)

internal class CompanionAdvertiser(context: Context) {
    private val nsd = context.applicationContext.getSystemService(Context.NSD_SERVICE) as NsdManager
    private var listener: NsdManager.RegistrationListener? = null

    fun start(deviceId: String, port: Int) {
        stop()
        val info = NsdServiceInfo().apply {
            serviceName = "reclash-cpn-$deviceId"
            serviceType = COMPANION_SERVICE_TYPE
            setPort(port)
            setAttribute("id", deviceId)
        }
        val registration = object : NsdManager.RegistrationListener {
            override fun onServiceRegistered(info: NsdServiceInfo) {}
            override fun onRegistrationFailed(info: NsdServiceInfo, code: Int) {}
            override fun onServiceUnregistered(info: NsdServiceInfo) {}
            override fun onUnregistrationFailed(info: NsdServiceInfo, code: Int) {}
        }
        runCatching { nsd.registerService(info, NsdManager.PROTOCOL_DNS_SD, registration) }
            .onSuccess { listener = registration }
    }

    fun stop() {
        listener?.let { active -> runCatching { nsd.unregisterService(active) } }
        listener = null
    }
}

internal class CompanionResolver(context: Context) {
    private val app = context.applicationContext
    private val nsd = app.getSystemService(Context.NSD_SERVICE) as NsdManager
    private val wifi = app.getSystemService(Context.WIFI_SERVICE) as WifiManager

    @Suppress("DEPRECATION")
    fun resolve(deviceId: String, timeoutMs: Long = 4000): CompanionEndpointAddress? {
        val multicast = wifi.createMulticastLock("reclash:companion").apply {
            setReferenceCounted(false)
            runCatching { acquire() }
        }
        val latch = CountDownLatch(1)
        val result = AtomicReference<CompanionEndpointAddress?>(null)
        val busy = AtomicBoolean(false)
        val queue = ArrayDeque<NsdServiceInfo>()

        val resolveListener = object : NsdManager.ResolveListener {
            override fun onServiceResolved(info: NsdServiceInfo) {
                val attrId = info.attributes["id"]?.toString(Charsets.UTF_8)
                val host = info.host
                val ipv4 = (host as? Inet4Address)?.hostAddress
                if (companionServiceMatches(info.serviceName, attrId, deviceId) &&
                    !ipv4.isNullOrBlank()
                ) {
                    result.set(CompanionEndpointAddress(ipv4, info.port))
                    latch.countDown()
                }
                busy.set(false)
                pump()
            }

            override fun onResolveFailed(info: NsdServiceInfo, code: Int) {
                busy.set(false)
                pump()
            }

            fun pump() {
                if (result.get() != null) return
                if (!busy.compareAndSet(false, true)) return
                val next = synchronized(queue) { queue.removeFirstOrNull() }
                if (next == null) busy.set(false) else nsd.resolveService(next, this)
            }
        }

        val discoveryListener = object : NsdManager.DiscoveryListener {
            override fun onServiceFound(info: NsdServiceInfo) {
                if (info.serviceType.contains("reclash-cpn") &&
                    companionServiceMatches(info.serviceName, null, deviceId)
                ) {
                    synchronized(queue) { queue.addLast(info) }
                    resolveListener.pump()
                }
            }

            override fun onServiceLost(info: NsdServiceInfo) {}
            override fun onDiscoveryStarted(type: String) {}
            override fun onDiscoveryStopped(type: String) {}
            override fun onStartDiscoveryFailed(type: String, code: Int) = latch.countDown()
            override fun onStopDiscoveryFailed(type: String, code: Int) {}
        }

        return try {
            nsd.discoverServices(COMPANION_SERVICE_TYPE, NsdManager.PROTOCOL_DNS_SD, discoveryListener)
            latch.await(timeoutMs, TimeUnit.MILLISECONDS)
            result.get()
        } catch (_: Exception) {
            null
        } finally {
            runCatching { nsd.stopServiceDiscovery(discoveryListener) }
            runCatching { multicast.release() }
        }
    }
}
