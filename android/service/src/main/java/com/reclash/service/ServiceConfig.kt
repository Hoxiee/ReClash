package com.reclash.service

import com.reclash.service.models.NotificationParams
import com.reclash.service.models.VpnOptions
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

object ServiceConfig {
    @Volatile
    private var currentVpnOptions: VpnOptions? = null
    private val mutableNotificationParams = MutableStateFlow(NotificationParams())

    val vpnOptions: VpnOptions?
        get() = currentVpnOptions

    val physicalNetworks = MutableStateFlow(PhysicalNetworks())
    val onDemandPaused = MutableStateFlow(false)
    val onDemandRevision = MutableStateFlow(0L)

    val notificationParams = mutableNotificationParams.asStateFlow()

    fun updateVpnOptions(options: VpnOptions) {
        if (currentVpnOptions == options) return
        currentVpnOptions = options
        onDemandRevision.value++
    }

    fun updateNotificationParams(params: NotificationParams) {
        mutableNotificationParams.value = params
    }
}


data class PhysicalNetworks(
    val ips: List<String> = emptyList(),
    val ssids: List<String> = emptyList(),
    val ssidUnknown: Boolean = false,
)
