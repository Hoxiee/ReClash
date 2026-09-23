package com.reclash.companion

import android.content.Context
import android.net.ConnectivityManager
import android.net.LinkAddress
import android.net.Network
import android.net.NetworkCapabilities
import java.net.Inet4Address

// GATE D: physical Wi-Fi/Ethernet Network and its RFC1918 IPv4; VPN/tun/loopback excluded. The
// phone dials through this Network's socket factory, never bindProcessToNetwork (app-wide hijack).
internal class CompanionNetwork(context: Context) {
    private val connectivity =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

    fun selectLanEndpoint(): CompanionLanEndpoint? {
        for (network in connectivity.allNetworks) {
            val caps = connectivity.getNetworkCapabilities(network) ?: continue
            if (!caps.isPhysicalLan()) continue
            val address = connectivity.privateIpv4(network) ?: continue
            return CompanionLanEndpoint(network, address)
        }
        return null
    }

    private fun NetworkCapabilities.isPhysicalLan(): Boolean {
        val physical = hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
            hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
        return physical && !hasTransport(NetworkCapabilities.TRANSPORT_VPN)
    }

    private fun ConnectivityManager.privateIpv4(network: Network): String? {
        val properties = getLinkProperties(network) ?: return null
        return properties.linkAddresses
            .map(LinkAddress::getAddress)
            .filterIsInstance<Inet4Address>()
            .firstOrNull { it.isSiteLocalAddress && !it.isLoopbackAddress }
            ?.hostAddress
    }
}

internal data class CompanionLanEndpoint(val network: Network, val ipv4: String)
