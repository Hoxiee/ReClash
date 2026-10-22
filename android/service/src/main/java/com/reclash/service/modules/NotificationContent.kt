package com.reclash.service.modules

import com.reclash.core.Core
import com.reclash.service.models.NotificationParams
import com.reclash.service.models.Traffic
import com.reclash.service.models.getTrafficState
import com.reclash.service.models.getTotalTrafficState
import com.reclash.service.models.speedText
import com.reclash.service.models.totalText
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.map

internal data class ExtendedNotificationParams(
    val title: String,
    val stopText: String,
    val showStopAction: Boolean,
    val contentText: String,
    val hideSensitive: Boolean,
    val publicText: String,
)

internal fun NotificationParams.projectContent(server: String?, speed: Traffic?, total: Traffic?): String =
    settings.components.mapNotNull { component ->
        when (component.type) {
            "currentServer" -> server?.takeIf(String::isNotBlank)?.let { "$serverText · $it" }
            "speed" -> speed?.takeUnless { component.hideWhenIdle && it.isIdle }?.speedText
            "sessionTraffic" -> total?.let { "$trafficText · ${it.totalText}" }
            else -> null
        }
    }.joinToString("\n").ifBlank { activeText }

internal val NotificationParams.updateIntervalMillis: Long?
    get() = when {
        settings.visibility != "detailed" -> null
        settings.components.any { it.type == "speed" || it.type == "sessionTraffic" } -> 1_000L
        settings.components.any { it.type == "currentServer" } && serverGroup != null -> 2_000L
        else -> null
    }

internal val NotificationParams.extended: ExtendedNotificationParams
    get() {
        val detailed = settings.visibility == "detailed"
        val types = if (detailed) settings.components.map { it.type }.toSet() else emptySet()
        val speed = if ("speed" in types) Core.getTrafficState(onlyStatisticsProxy) else null
        val total = if ("sessionTraffic" in types) Core.getTotalTrafficState(onlyStatisticsProxy) else null
        val server = serverGroup?.takeIf { "currentServer" in types }?.let {
            runCatching { Core.getNotificationServer(it) }.getOrNull()
        }
        return ExtendedNotificationParams(
            if (detailed) title.ifBlank { "ReClash" } else "ReClash",
            stopText,
            detailed && showStopAction && settings.showStopAction,
            if (detailed) projectContent(server, speed, total) else activeText,
            settings.hideSensitiveOnLockScreen,
            activeText,
        )
    }

@OptIn(ExperimentalCoroutinesApi::class)
internal fun notificationUpdates(params: Flow<NotificationParams>, screenOn: Flow<Boolean>): Flow<NotificationParams> =
    combine(params.map { it.updateIntervalMillis }, screenOn) { interval, visible -> interval.takeIf { visible } }
        .distinctUntilChanged()
        .flatMapLatest { interval ->
            if (interval == null) flowOf(Unit) else flow {
                while (true) { emit(Unit); delay(interval) }
            }
        }.combine(params) { _, current -> current }
