package com.reclash.models

import com.reclash.service.models.VpnOptions
import com.google.gson.annotations.SerializedName

data class SharedState(
    val startTip: String = "Starting VPN...",
    val stopTip: String = "Stopping VPN...",
    val pauseTip: String = "Pausing VPN...",
    val crashlytics: Boolean = true,
    val currentProfileName: String = "ReClash",
    val stopText: String = "Stop",
    val pauseText: String = "Pause",
    val resumeText: String = "Resume",
    val onlyStatisticsProxy: Boolean = false,
    val vpnOptions: VpnOptions? = null,
    val setupParams: SetupParams? = null,
)

data class SetupParams(
    @SerializedName("test-url")
    val testUrl: String,
    @SerializedName("selected-map")
    val selectedMap: Map<String, String>,
)
