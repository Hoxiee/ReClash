package com.reclash.service.modules

import android.app.Service
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkCapabilities.TRANSPORT_SATELLITE
import android.net.NetworkCapabilities.TRANSPORT_USB
import android.net.NetworkRequest
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.getSystemService
import com.reclash.core.Core
import com.reclash.service.WifiSsid
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.InetAddress
import java.util.concurrent.ConcurrentHashMap

private data class NetworkInfo(
    @Volatile var losingUntilMillis: Long = 0,
    @Volatile var dnsList: List<InetAddress> = emptyList(),
    @Volatile var ipv4List: List<String> = emptyList(),
    @Volatile var ssid: String? = null,
) {
    val priorityPenalty: Int
        get() = if (losingUntilMillis > System.currentTimeMillis()) 10 else 0
}

internal class NetworkObserveModule(private val service: Service) : ServiceModule {

    // Union across all networks: a phone on wifi+cellular belongs to both LANs at once.
    var onPhysicalNetworksChanged: ((ips: List<String>, ssids: List<String>) -> Unit)? = null

    private val networkInfos = ConcurrentHashMap<Network, NetworkInfo>()
    private val connectivity by lazy {
        service.getSystemService<ConnectivityManager>()
    }
    private val mainHandler = Handler(Looper.getMainLooper())
    private var currentDnsList = listOf<String>()
    private var lastIpv4Union = emptyList<String>()
    private var lastSsidUnion = emptyList<String>()

    private val request = NetworkRequest.Builder().apply {
        addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
        addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            addCapability(NetworkCapabilities.NET_CAPABILITY_FOREGROUND)
        }
        addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_RESTRICTED)
    }.build()

    // The flags constructor exists only from S on.
    private val callback: ConnectivityManager.NetworkCallback =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            object : ConnectivityManager.NetworkCallback(
                ConnectivityManager.NetworkCallback.FLAG_INCLUDE_LOCATION_INFO,
            ) {
                override fun onAvailable(network: Network) = handleAvailable(network)

                override fun onLosing(network: Network, maxMsToLive: Int) =
                    handleLosing(network, maxMsToLive)

                override fun onLost(network: Network) = handleLost(network)

                override fun onCapabilitiesChanged(
                    network: Network,
                    capabilities: NetworkCapabilities,
                ) = handleCapabilitiesChanged(network, capabilities)

                override fun onLinkPropertiesChanged(
                    network: Network,
                    linkProperties: LinkProperties,
                ) = handleLinkPropertiesChanged(network, linkProperties)
            }
        } else {
            object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) = handleAvailable(network)

                override fun onLosing(network: Network, maxMsToLive: Int) =
                    handleLosing(network, maxMsToLive)

                override fun onLost(network: Network) = handleLost(network)

                override fun onCapabilitiesChanged(
                    network: Network,
                    capabilities: NetworkCapabilities,
                ) = handleCapabilitiesChanged(network, capabilities)

                override fun onLinkPropertiesChanged(
                    network: Network,
                    linkProperties: LinkProperties,
                ) = handleLinkPropertiesChanged(network, linkProperties)
            }
        }

    private fun handleAvailable(network: Network) {
        networkInfos[network] = NetworkInfo()
        updateDns()
        updatePhysical()
    }

    private fun handleLosing(network: Network, maxMsToLive: Int) {
        val info = networkInfos[network] ?: return
        info.losingUntilMillis = System.currentTimeMillis() + maxMsToLive
        updateDns()
        if (maxMsToLive > 0) {
            mainHandler.postDelayed({
                if (networkInfos.containsKey(network)) {
                    updateDns()
                }
            }, maxMsToLive.toLong() + 50)
        }
    }

    private fun handleLost(network: Network) {
        networkInfos.remove(network)
        updateDns()
        updatePhysical()
    }

    private fun handleCapabilitiesChanged(
        network: Network,
        capabilities: NetworkCapabilities,
    ) {
        val info = networkInfos[network] ?: return
        info.ssid = if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
            WifiSsid.live(service, capabilities)
        } else {
            null
        }
        updatePhysical()
    }

    private fun handleLinkPropertiesChanged(network: Network, linkProperties: LinkProperties) {
        networkInfos[network]?.let { info ->
            info.dnsList = linkProperties.dnsServers
            info.ipv4List = linkProperties.linkAddresses
                .mapNotNull { (it.address as? Inet4Address)?.hostAddress }
        }
        updateDns()
        updatePhysical()
    }

    override fun start() {
        updateDns()
        connectivity?.registerNetworkCallback(request, callback)
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
        val dnsList = networkInfos.asSequence()
            .minByOrNull(::networkPriority)
            ?.value
            ?.dnsList
            .orEmpty()
            .map { address -> address.asSocketAddressText(DNS_PORT) }
            .distinct()
        if (dnsList == currentDnsList) {
            return
        }
        currentDnsList = dnsList
        Core.updateDNS(dnsList.joinToString(","))
    }

    @Synchronized
    private fun updatePhysical() {
        val ipv4Union = networkInfos.values.flatMap { it.ipv4List }.distinct().sorted()
        val ssidUnion = networkInfos.values.mapNotNull { it.ssid }.distinct().sorted()
        if (ipv4Union == lastIpv4Union && ssidUnion == lastSsidUnion) {
            return
        }
        lastIpv4Union = ipv4Union
        lastSsidUnion = ssidUnion
        onPhysicalNetworksChanged?.invoke(ipv4Union, ssidUnion)
    }

    override fun stop() {
        mainHandler.removeCallbacksAndMessages(null)
        try {
            connectivity?.unregisterNetworkCallback(callback)
        } finally {
            networkInfos.clear()
            lastIpv4Union = emptyList()
            lastSsidUnion = emptyList()
            updateDns()
        }
    }
}

private const val DNS_PORT = 53

private fun InetAddress.asSocketAddressText(port: Int): String = when (this) {
    is Inet6Address -> "[$hostAddress]:$port"
    is Inet4Address -> "$hostAddress:$port"
    else -> error("Unsupported address type: ${javaClass.name}")
}
