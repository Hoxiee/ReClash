package com.reclash.service.models

import com.google.gson.Gson
import com.reclash.common.AccessControlMode
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.InetAddress

data class AccessControlProps(
    val enable: Boolean,
    val mode: AccessControlMode,
    val acceptList: List<String>,
    val rejectList: List<String>,
)

data class VpnOptions(
    val enable: Boolean,
    val port: Int,
    val ipv6: Boolean,
    val dnsHijacking: Boolean,
    val accessControlProps: AccessControlProps,
    val allowBypass: Boolean,
    val systemProxy: Boolean,
    val bypassDomain: List<String>,
    val stack: String,
    val routeAddress: List<String>,
    val mtu: Int = 0,
    val congestionController: String? = null,
    val routeExcludeAddress: List<String> = emptyList(),
    val smartPauseEnabled: Boolean = false,
    val smartPauseNetworks: List<String> = emptyList(),
    val smartPauseCloseConnections: Boolean = false,
    val smartPauseStrict: Boolean = false,
    val smartPauseFullStop: Boolean = false,
    val desyncEnabled: Boolean = false,
    val desyncOnly: Boolean = false,
    val desyncPort: Int = 0,
    val desyncStrategy: List<String> = emptyList(),
    val desyncCacheTtl: Int = 0,
    val desyncCacheEnabled: Boolean = true,
    val desyncTesting: Boolean = false,
)

data class CIDR(
    val address: InetAddress,
    val prefixLength: Int,
)

fun VpnOptions.getIpv4RouteAddress(): List<CIDR> = routeAddress
    .map(String::toCIDR)
    .filter { it.address is Inet4Address }

fun VpnOptions.getIpv6RouteAddress(): List<CIDR> = routeAddress
    .map(String::toCIDR)
    .filter { it.address is Inet6Address }

fun VpnOptions.getIpv4RouteExcludeAddress(): List<CIDR> = routeExcludeAddress
    .map(String::toCIDR)
    .filter { it.address is Inet4Address }

fun VpnOptions.getIpv6RouteExcludeAddress(): List<CIDR> = routeExcludeAddress
    .map(String::toCIDR)
    .filter { it.address is Inet6Address }

private const val DEFAULT_MTU = 1500
private const val MIN_MTU = 1280
private const val MAX_MTU = 65535
private const val DEFAULT_CONGESTION_CONTROLLER = "cubic"

private val tunOptionsGson = Gson()

val VpnOptions.tunMtu: Int
    get() = if (mtu <= 0) DEFAULT_MTU else mtu.coerceIn(MIN_MTU, MAX_MTU)

val VpnOptions.tunCongestionController: String
    get() = congestionController?.takeIf { it.isNotBlank() } ?: DEFAULT_CONGESTION_CONTROLLER

fun VpnOptions.tunOptions(): String = tunOptionsGson.toJson(
    mapOf(
        "mtu" to tunMtu,
        "congestion-controller" to tunCongestionController,
    ),
)

fun String.toCIDR(): CIDR {
    val parts = split("/")
    require(parts.size == 2) { "Invalid CIDR format: $this" }
    val ipAddress = parts[0]
    val prefixLength = parts[1].toIntOrNull()
        ?: throw IllegalArgumentException("Invalid prefix length: ${parts[1]}")

    val address = InetAddress.getByName(ipAddress)
    val maxPrefix = if (address.address.size == 4) 32 else 128
    require(prefixLength in 0..maxPrefix) {
        "Invalid prefix length $prefixLength for $ipAddress"
    }

    return CIDR(address, prefixLength)
}
