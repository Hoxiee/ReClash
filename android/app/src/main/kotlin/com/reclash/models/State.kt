package com.reclash.models

import com.reclash.service.models.VpnOptions
import com.reclash.service.models.NotificationSettings
import com.google.gson.JsonObject

data class SharedState(
    val startTip: String = "Starting VPN...",
    val stopTip: String = "Stopping VPN...",
    val localNetworkTip: String =
        "Local network permission denied: using the gvisor stack, LAN is unreachable.",
    val currentProfileName: String = "ReClash",
    val stopText: String = "Stop",
    val onlyStatisticsProxy: Boolean = false,
    val showStopAction: Boolean = true,
    val notificationSettings: NotificationSettings = NotificationSettings(),
    val notificationActiveText: String = "Protection active",
    val notificationServerText: String = "Current server",
    val notificationTrafficText: String = "Session traffic",
    val notificationServerGroup: String? = null,
    val vpnOptions: VpnOptions? = null,
    // Opaque on purpose: Dart owns the keys and the Core must receive them untouched.
    val setupParams: JsonObject? = null,
)
