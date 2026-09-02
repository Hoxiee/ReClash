package com.reclash.common

import com.google.gson.annotations.SerializedName

enum class QuickAction {
    STOP,
    START,
    TOGGLE,
    PAUSE,
    RESUME,
}

enum class BroadcastAction {
    VPN_START_REQUESTED,
    VPN_REVOKED,
}

enum class AccessControlMode {
    @SerializedName("acceptSelected")
    ACCEPT_SELECTED,

    @SerializedName("rejectSelected")
    REJECT_SELECTED,
}
