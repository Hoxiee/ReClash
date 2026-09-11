package com.reclash.service

import com.google.gson.Gson
import com.google.gson.JsonParser
import com.reclash.service.models.NotificationParams
import com.reclash.service.models.VpnOptions
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

data class PauseState(
    val paused: Boolean = false,
    val manual: Boolean = false,
)

data class SmartRoutingStatus(
    val enabled: Boolean = false,
    val node: String = "",
    val delay: Int = 0,
    val reason: String = "",
    val searching: Boolean = false,
    val terrain: String = "unknown",
    val mode: String = "",
)

data class DoctorStatus(
    val revision: Long = 0,
    val state: String = "observing",
    val health: String = "unknown",
    val confidence: String = "insufficient",
    val causeCode: String = "",
)

object ServiceConfig {
    private val mutableVpnOptions = MutableStateFlow<VpnOptions?>(null)
    private val mutableNotificationParams = MutableStateFlow(NotificationParams())
    private val mutablePauseState = MutableStateFlow(PauseState())
    private val mutableSmartRoutingStatus = MutableStateFlow(SmartRoutingStatus())
    private val mutableDoctorStatus = MutableStateFlow(DoctorStatus())
    private val gson = Gson()

    @Volatile
    private var sessionStartedAtMillis = 0L

    val vpnOptions: VpnOptions?
        get() = mutableVpnOptions.value

    val vpnOptionsFlow = mutableVpnOptions.asStateFlow()

    val notificationParams = mutableNotificationParams.asStateFlow()

    val pauseState = mutablePauseState.asStateFlow()

    val smartRoutingStatus = mutableSmartRoutingStatus.asStateFlow()

    val doctorStatus = mutableDoctorStatus.asStateFlow()

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

    fun acceptCoreEvent(raw: String?) {
        val arguments = runCatching {
            JsonParser.parseString(raw).asJsonObject.getAsJsonArray("arguments")
        }.getOrNull() ?: return
        arguments.forEach { item ->
            val event = item.takeIf { it.isJsonObject }?.asJsonObject ?: return@forEach
            when (event.get("type")?.asString) {
                "rcxStatus" -> runCatching {
                    event.get("data")?.takeIf { it.isJsonObject }?.asJsonObject
                        ?.let { gson.fromJson(it, SmartRoutingStatus::class.java) }
                }.getOrNull()?.let { mutableSmartRoutingStatus.value = it }
                "doctorStatus" -> runCatching {
                    event.get("data")?.takeIf { it.isJsonObject }?.asJsonObject
                        ?.let { gson.fromJson(it, DoctorStatus::class.java) }
                }.getOrNull()?.let { status ->
                    if (status.revision >= mutableDoctorStatus.value.revision) {
                        mutableDoctorStatus.value = status
                    }
                }
            }
        }
    }

    fun resetCoreStatuses() {
        mutableSmartRoutingStatus.value = SmartRoutingStatus()
        mutableDoctorStatus.value = DoctorStatus()
    }

    fun updateSessionStartedAt(uptimeMillis: Long) {
        sessionStartedAtMillis = uptimeMillis
    }
}
