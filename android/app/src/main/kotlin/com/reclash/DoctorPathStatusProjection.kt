package com.reclash

internal enum class DoctorPathKind(val wireValue: String) {
    VPN("vpn"),
    LOCAL_PROXY("localProxy"),
}

internal enum class DoctorPathPhase(val wireValue: String) {
    ACTIVE("active"),
    INACTIVE("inactive"),
    PAUSED("paused"),
}

internal data class DoctorPathStatus(
    val pathKind: String,
    val phase: String,
    val generation: Long,
    val timestamp: Long,
)

internal class DoctorPathStatusProjection(
    private val now: () -> Long = System::currentTimeMillis,
) {
    private var generation = 0L
    private var timestamp = 0L
    private var current: Pair<DoctorPathKind, DoctorPathPhase>? = null

    fun update(
        pathKind: DoctorPathKind,
        phase: DoctorPathPhase,
    ): DoctorPathStatus? {
        if (current == pathKind to phase) {
            return null
        }
        current = pathKind to phase
        timestamp = maxOf(timestamp + 1, now())
        return DoctorPathStatus(
            pathKind = pathKind.wireValue,
            phase = phase.wireValue,
            generation = ++generation,
            timestamp = timestamp,
        )
    }
}
