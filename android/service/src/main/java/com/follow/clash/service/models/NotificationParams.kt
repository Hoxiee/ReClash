package com.reclash.service.models

data class NotificationParams(
    val title: String = "ReClash",
    val stopText: String = "STOP",
    val onlyStatisticsProxy: Boolean = false,
    val showStopAction: Boolean = true,
)
