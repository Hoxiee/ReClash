package com.reclash.service

import android.Manifest
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkCapabilities.TRANSPORT_SATELLITE
import android.net.NetworkCapabilities.TRANSPORT_USB
import android.net.NetworkRequest
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import androidx.core.content.ContextCompat
import androidx.core.content.getSystemService
import com.reclash.common.GlobalState
import com.reclash.core.Core
import com.reclash.service.modules.TrustedNetworkMatcher
import com.reclash.service.modules.sendNetworkHint
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.InetAddress
import java.util.concurrent.ConcurrentHashMap

private data class NetworkInfo(
    @Volatile var losingUntilMillis: Long = 0,
    @Volatile var dnsList: List<InetAddress> = emptyList(),
) {
    val priorityPenalty: Int
        get() = if (losingUntilMillis > System.currentTimeMillis()) 10 else 0
}

// Outlives every service run: the Core also tests delays and updates providers
// while stopped, and a `system` nameserver has no upstream until DNS arrives here.
object NetworkObserver {

    private val networkInfos = ConcurrentHashMap<Network, NetworkInfo>()
    private val connectivity by lazy {
        GlobalState.application.getSystemService<ConnectivityManager>()
    }
    private val handler by lazy {
        Handler(HandlerThread("NetworkObserve").apply { start() }.looper)
    }
    private var currentDnsList = listOf<String>()
    private var currentNetwork: Network? = null
    private val wifiInfos = ConcurrentHashMap<Network, WifiInfo>()

    private val request = NetworkRequest.Builder().apply {
        addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
        addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            addCapability(NetworkCapabilities.NET_CAPABILITY_FOREGROUND)
        }
        addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_RESTRICTED)
    }.build()

    private val registrationLock = Any()
    private var callback: ConnectivityManager.NetworkCallback? = null
    private var includesSsid = false
    private var optionsRevision = -1L
    private var revisionJob: Job? = null
    @Volatile
    private var observing = false

    private class ObserverCallback : ConnectivityManager.NetworkCallback {
        constructor() : super()
        constructor(flags: Int) : super(flags)

        override fun onAvailable(network: Network) {
            networkInfos[network] = NetworkInfo()
            scheduleUpdateDns()
            requestRegistrationCheck()
        }

        override fun onLosing(network: Network, maxMsToLive: Int) {
            val info = networkInfos[network] ?: return
            info.losingUntilMillis = System.currentTimeMillis() + maxMsToLive
            scheduleUpdateDns()
            if (maxMsToLive > 0) {
                handler.postDelayed({
                    if (networkInfos.containsKey(network)) {
                        updateDns()
                    }
                }, maxMsToLive.toLong() + 50)
            }
        }

        override fun onLost(network: Network) {
            networkInfos.remove(network)
            wifiInfos.remove(network)
            scheduleUpdateDns()
        }

        override fun onLinkPropertiesChanged(network: Network, linkProperties: LinkProperties) {
            networkInfos[network]?.dnsList = linkProperties.dnsServers
            scheduleUpdateDns()
        }

        // A captive portal or a metered flag can change without a new network.
        override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                (capabilities.transportInfo as? WifiInfo)?.let { wifiInfos[network] = it }
            }
            if (networkInfos.containsKey(network)) scheduleUpdateDns()
        }
    }

    private val updateDnsTask = Runnable(::updateDns)

    // A switch arrives as a burst, and a network that just came up has no DNS
    // until its link properties follow; the Core flushes its cache per list.
    private fun scheduleUpdateDns() {
        if (!observing) return
        handler.removeCallbacks(updateDnsTask)
        handler.postDelayed(updateDnsTask, DNS_UPDATE_DELAY_MILLIS)
    }

    private fun requestRegistrationCheck() {
        if (!observing) return
        handler.removeCallbacks(checkRegistration)
        handler.post(checkRegistration)
    }

    // Android sends nothing when location is granted while the service runs (a revoke kills the
    // process), so only a missing grant is polled, and only while an SSID rule wants it.
    private val checkRegistration: Runnable = Runnable {
        val ssidRules = ServiceConfig.vpnOptions?.let { options ->
            options.onDemandEnabled && options.onDemandNetworks.any { !TrustedNetworkMatcher.isSubnetRule(it) }
        } == true
        val needsSsid = ssidRules && ContextCompat.checkSelfPermission(
            GlobalState.application, Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        val registered = runCatching { register(needsSsid) }
            .onFailure { GlobalState.log("Unable to refresh physical networks: $it") }
            .getOrDefault(false)
        if (!observing) return@Runnable
        if (registered) scheduleUpdateDns()
        when {
            synchronized(registrationLock) { callback == null } ->
                handler.postDelayed(checkRegistration, REGISTRATION_RETRY_MILLIS)
            ssidRules && !needsSsid ->
                handler.postDelayed(checkRegistration, LOCATION_PERMISSION_POLL_MILLIS)
        }
    }

    private fun register(needsSsid: Boolean): Boolean = synchronized(registrationLock) {
        val revision = ServiceConfig.onDemandRevision.value
        if (!observing || callback != null && revision == optionsRevision && includesSsid == needsSsid) {
            return@synchronized false
        }
        callback?.let { runCatching { connectivity?.unregisterNetworkCallback(it) } }
        callback = null
        wifiInfos.clear()
        val next = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && needsSsid) {
            ObserverCallback(ConnectivityManager.NetworkCallback.FLAG_INCLUDE_LOCATION_INFO)
        } else ObserverCallback()
        connectivity?.registerNetworkCallback(request, next)
        callback = next
        includesSsid = needsSsid
        optionsRevision = revision
        true
    }

    @Synchronized
    fun start() {
        if (observing) return
        observing = true
        revisionJob = GlobalState.launch {
            ServiceConfig.onDemandRevision.collect { requestRegistrationCheck() }
        }
    }

    private fun networkPriority(entry: Map.Entry<Network, NetworkInfo>): Int {
        val capabilities = connectivity?.getNetworkCapabilities(entry.key)
        return when {
            capabilities == null -> 100
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN) -> 90
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> 0
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> 1
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                capabilities.hasTransport(TRANSPORT_USB) -> 2

            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH) -> 3
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> 4
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM &&
                capabilities.hasTransport(TRANSPORT_SATELLITE) -> 5

            else -> 20
        } + entry.value.priorityPenalty
    }

    @Synchronized
    private fun updateDns() {
        publishPhysicalNetworks()
        val preferred = networkInfos.entries.minByOrNull(::networkPriority)
        val dnsList = preferred
            ?.value
            ?.dnsList
            .orEmpty()
            .map { address -> address.asSocketAddressText(DNS_PORT) }
            .distinct()
        if (dnsList != currentDnsList) {
            currentDnsList = dnsList
            Core.updateDNS(dnsList.joinToString(","))
        }
        val network = preferred?.key ?: return
        connectivity?.getNetworkCapabilities(network)?.let { capabilities ->
            sendNetworkHint(
                transport = capabilities.transportName,
                id = dnsList.joinToString(","),
                metered = !capabilities.hasCapability(
                    NetworkCapabilities.NET_CAPABILITY_NOT_METERED,
                ),
                portal = capabilities.hasCapability(
                    NetworkCapabilities.NET_CAPABILITY_CAPTIVE_PORTAL,
                ),
            )
        }
        // Sockets protected onto the network we left stay bound to it; closing
        // them makes apps reconnect now instead of after a TCP timeout.
        if (currentNetwork != null && currentNetwork != network) {
            Core.resetNetwork()
        }
        currentNetwork = network
    }

    private fun publishPhysicalNetworks() {
        val networks = connectivity?.allNetworks.orEmpty().filter { network ->
            connectivity?.getNetworkCapabilities(network)?.let { caps ->
                !caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) &&
                    (caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
                     caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) ||
                     caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR))
            } == true
        }
        val ips = networks.flatMap { network ->
            connectivity?.getLinkProperties(network)?.linkAddresses.orEmpty()
                .map { it.address.hostAddress.orEmpty() }.filter { it.isNotEmpty() }
        }
        val needsSsid = ServiceConfig.vpnOptions?.let { options ->
            options.onDemandEnabled && options.onDemandNetworks.any { !TrustedNetworkMatcher.isSubnetRule(it) }
        } == true
        val ssids = if (needsSsid) networks.mapNotNull { network ->
            val caps = connectivity?.getNetworkCapabilities(network)
            val info = wifiInfos[network]
            @Suppress("DEPRECATION")
            val raw = info?.ssid ?: if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                GlobalState.application.getSystemService<WifiManager>()?.connectionInfo?.ssid
            } else null
            raw?.removeSurrounding("\"")?.takeIf { it.isNotEmpty() && it != WifiManager.UNKNOWN_SSID && it != "0x" }
        } else emptyList()
        val wifiPresent = networks.any { network ->
            connectivity?.getNetworkCapabilities(network)?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true
        }
        ServiceConfig.physicalNetworks.value = if (observing) {
            PhysicalNetworks(ips.distinct(), ssids.distinct(), needsSsid && wifiPresent && ssids.isEmpty())
        } else PhysicalNetworks()
    }

    fun stop() {
        revisionJob?.cancel()
        val registered = synchronized(registrationLock) {
            observing = false
            callback.also { callback = null }
        }
        handler.removeCallbacksAndMessages(null)
        try {
            registered?.let { connectivity?.unregisterNetworkCallback(it) }
        } finally {
            networkInfos.clear()
            wifiInfos.clear()
            updateDns()
            currentNetwork = null
        }
    }
}

private val NetworkCapabilities.transportName: String
    get() = when {
        hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
        hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
        hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
        else -> "other"
    }

private const val DNS_PORT = 53
private const val DNS_UPDATE_DELAY_MILLIS = 200L
private const val REGISTRATION_RETRY_MILLIS = 2_000L
private const val LOCATION_PERMISSION_POLL_MILLIS = 30_000L

private fun InetAddress.asSocketAddressText(port: Int): String = when (this) {
    is Inet6Address -> "[$hostAddress]:$port"
    is Inet4Address -> "$hostAddress:$port"
    else -> error("Unsupported address type: ${javaClass.name}")
}
