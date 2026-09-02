package com.reclash.service

import android.content.Context
import android.net.NetworkCapabilities
import android.net.wifi.WifiInfo

// Null means "no name": not on Wi-Fi, or withheld by a missing location grant.
internal object WifiSsid {

    fun normalize(raw: String?): String? {
        val trimmed = raw?.trim()?.removeSurrounding("\"")?.trim() ?: return null
        return if (trimmed.isEmpty() || trimmed == "<unknown ssid>") null else trimmed
    }

    fun fromTransportInfo(caps: NetworkCapabilities?): String? {
        val info = runCatching { caps?.transportInfo }.getOrNull() as? WifiInfo ?: return null
        return normalize(info.ssid)
    }

    fun live(context: Context, caps: NetworkCapabilities? = null): String? {
        fromTransportInfo(caps)?.let { return it }
        @Suppress("DEPRECATION") // connectionInfo: the pre-Q transportInfo fallback.
        return runCatching {
            val wm = context.applicationContext
                .getSystemService(Context.WIFI_SERVICE) as? android.net.wifi.WifiManager
            normalize(wm?.connectionInfo?.ssid)
        }.getOrNull()
    }
}
