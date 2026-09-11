package com.reclash.models

import com.google.gson.annotations.SerializedName
import com.reclash.service.models.VpnOptions

data class NotificationComponent(
    val type: String,
    val doctorPriority: String? = null,
    val hideWhenIdle: Boolean? = null,
    val group: String? = null,
)

data class NotificationSettings(
    val components: List<NotificationComponent>? = null,
    val contentMode: String = "adaptive",
    val doctorPriority: String = "problems",
    val showSessionTraffic: Boolean = true,
    val hideIdleSpeed: Boolean = true,
    val showPauseAction: Boolean = true,
    val showStopAction: Boolean = true,
    val hideSensitiveOnLockScreen: Boolean = true,
    val visibility: String = "detailed",
    val subscriptionReminders: Boolean = true,
)

data class SharedState(
    val startTip: String = "Starting VPN...",
    val stopTip: String = "Stopping VPN...",
    val pauseTip: String = "Pausing VPN...",
    val crashlytics: Boolean = false,
    val currentProfileName: String = "ReClash",
    val stopText: String = "Stop",
    val pauseText: String = "Pause",
    val resumeText: String = "Resume",
    val pausedText: String = "Paused",
    val smartRoutingText: String = "Smart Routing",
    val smartRoutingSearchingText: String = "Searching",
    val connectionDoctorText: String = "Connection Doctor",
    val doctorExaminingText: String = "Checking connection",
    val doctorHealthyText: String = "Connection healthy",
    val doctorDegradedText: String = "Connection degraded",
    val doctorBrokenText: String = "Problem found",
    val doctorObservingText: String = "Observing traffic",
    val sessionTrafficText: String = "Session traffic",
    val networkStateText: String = "Network",
    val currentServerText: String = "Current server",
    val networkNormalText: String = "Normal",
    val networkWhitelistText: String = "Whitelist",
    val networkPortalText: String = "Captive portal",
    val networkOfflineText: String = "Offline",
    val networkUnknownText: String = "Unknown",
    val activeText: String = "Protection active",
    val activeServerGroup: String? = null,
    val onlyStatisticsProxy: Boolean = false,
    val notificationSettings: NotificationSettings = NotificationSettings(),
    val pureBlackTheme: Boolean = false,
    val autoRun: Boolean = false,
    val vpnOptions: VpnOptions? = null,
    val setupParams: SetupParams? = null,
)

data class SetupParams(
    @SerializedName("test-url")
    val testUrl: String,
    @SerializedName("selected-map")
    val selectedMap: Map<String, String>,
)
