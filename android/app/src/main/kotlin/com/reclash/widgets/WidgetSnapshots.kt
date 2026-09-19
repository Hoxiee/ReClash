package com.reclash.widgets

import android.content.Context
import com.reclash.RunState
import com.reclash.ServiceController
import com.reclash.ServiceState
import com.reclash.common.GlobalState
import com.reclash.core.Core
import com.reclash.service.ServiceConfig
import com.reclash.service.models.getActiveServerState
import com.reclash.service.models.getTotalTrafficState
import com.reclash.service.models.getTrafficState
import com.reclash.sharedState

// Everything the four widgets draw comes from here, so a redraw of one can
// never disagree with a redraw of another.
internal object WidgetSnapshots {
    fun current(context: Context): WidgetSnapshot {
        val stored = WidgetStore.load(context)
        val shared = runCatching { GlobalState.application.sharedState }.getOrNull()
        val routing = ServiceConfig.smartRoutingStatus.value
        val doctor = ServiceConfig.doctorStatus.value
        val vpn = ServiceConfig.vpnOptions
        val runState = ServiceState.runState.value
        val running = runState == RunState.STARTED || runState == RunState.PAUSED
        val onlyStatisticsProxy = shared?.onlyStatisticsProxy ?: false
        val speed = if (running) {
            runCatching { Core.getTrafficState(onlyStatisticsProxy) }.getOrNull()
        } else {
            null
        }
        val total = if (running) {
            runCatching { Core.getTotalTrafficState(onlyStatisticsProxy) }.getOrNull()
        } else {
            null
        }
        val group = shared?.activeServerGroup?.takeIf { it.isNotBlank() } ?: stored.group
        val snapshot = WidgetSnapshot(
            runState = runState,
            profile = shared?.currentProfileName?.takeIf { it.isNotBlank() } ?: stored.profile,
            group = group,
            node = nodeOf(running, group, routing.node, shared?.setupParams?.selectedMap, stored),
            delay = if (routing.delay > 0) routing.delay else stored.delay,
            terrain = routing.terrain.takeIf { it.isNotBlank() } ?: stored.terrain,
            routingEnabled = routing.enabled,
            byedpiOnly = vpn?.let { it.desyncEnabled && it.desyncOnly } ?: false,
            searching = routing.searching,
            doctorState = doctor.state,
            doctorHealth = doctor.health,
            upSpeed = speed?.up ?: 0L,
            downSpeed = speed?.down ?: 0L,
            sessionUp = total?.up ?: 0L,
            sessionDown = total?.down ?: 0L,
            startedAtMillis = if (running) ServiceController.getRunTimeMillis() else 0L,
        )
        WidgetStore.save(context, snapshot)
        return snapshot
    }

    private fun nodeOf(
        running: Boolean,
        group: String,
        routingNode: String,
        selectedMap: Map<String, String>?,
        stored: WidgetSnapshot,
    ): String {
        if (running && group.isNotBlank()) {
            runCatching { Core.getActiveServerState(group) }.getOrNull()
                ?.takeIf { it.isNotBlank() }
                ?.let { return it }
        }
        routingNode.takeIf { it.isNotBlank() }?.let { return it }
        selectedMap?.get(group)?.takeIf { it.isNotBlank() }?.let { return it }
        return stored.node
    }
}
