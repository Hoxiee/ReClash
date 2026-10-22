package com.reclash.service.models

data class NotificationComponent(
    val type: String,
    val hideWhenIdle: Boolean = true,
    val group: String? = null,
)

data class NotificationSettings(
    val visibility: String = "detailed",
    val components: List<NotificationComponent> = listOf(
        NotificationComponent("currentServer"),
        NotificationComponent("speed"),
        NotificationComponent("sessionTraffic"),
    ),
    val showStopAction: Boolean = true,
    val hideSensitiveOnLockScreen: Boolean = true,
    val subscriptionReminders: Boolean = true,
)

data class NotificationParams(
    val title: String = "ReClash",
    val stopText: String = "STOP",
    val onlyStatisticsProxy: Boolean = false,
    val showStopAction: Boolean = true,
    val settings: NotificationSettings = NotificationSettings(),
    val activeText: String = "Protection active",
    val serverText: String = "Current server",
    val trafficText: String = "Session traffic",
    val serverGroup: String? = null,
)
