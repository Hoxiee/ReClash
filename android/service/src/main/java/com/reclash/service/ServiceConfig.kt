package com.reclash.service

import com.reclash.service.models.NotificationParams
import com.reclash.service.models.VpnOptions
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

data class PauseState(
    val paused: Boolean = false,
    val manual: Boolean = false,
)

object ServiceConfig {
    private val mutableVpnOptions = MutableStateFlow<VpnOptions?>(null)
    private val mutableNotificationParams = MutableStateFlow(NotificationParams())
    private val mutablePauseState = MutableStateFlow(PauseState())

    @Volatile
    private var sessionStartedAtMillis = 0L

    val vpnOptions: VpnOptions?
        get() = mutableVpnOptions.value

    val vpnOptionsFlow = mutableVpnOptions.asStateFlow()

    val notificationParams = mutableNotificationParams.asStateFlow()

    val pauseState = mutablePauseState.asStateFlow()

    val sessionStartedAt: Long
        get() = sessionStartedAtMillis

    fun updateVpnOptions(options: VpnOptions) {
        mutableVpnOptions.value = options
    }

    fun updateNotificationParams(params: NotificationParams) {
        mutableNotificationParams.value = params
    }

    fun updatePauseState(state: PauseState) {
        mutablePauseState.value = state
    }

    fun updateSessionStartedAt(uptimeMillis: Long) {
        sessionStartedAtMillis = uptimeMillis
    }
}
