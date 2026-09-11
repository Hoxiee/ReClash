package com.reclash.service

import com.reclash.common.AccessControlMode
import com.reclash.common.GlobalState
import com.reclash.service.models.AccessControlProps
import com.reclash.service.models.NotificationComponent
import com.reclash.service.models.NotificationParams
import com.reclash.service.models.parseActiveServer
import com.reclash.service.modules.channelId
import com.reclash.service.modules.extended
import com.reclash.service.modules.needsTicker
import com.reclash.service.modules.projectContent
import com.reclash.service.models.VpnOptions
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertSame
import org.junit.Test

private fun vpnOptions(port: Int) = VpnOptions(
    enable = true,
    port = port,
    ipv6 = false,
    dnsHijacking = true,
    accessControlProps = AccessControlProps(
        enable = true,
        mode = AccessControlMode.REJECT_SELECTED,
        acceptList = listOf("com.example.accepted"),
        rejectList = listOf("com.example.rejected"),
    ),
    allowBypass = true,
    systemProxy = false,
    bypassDomain = listOf("example.test"),
    stack = "system",
    routeAddress = listOf("0.0.0.0/0"),
)

class ServiceConfigTest {
    @Test
    fun `notification params default to the app name and stop label`() {
        val defaults = NotificationParams()

        assertEquals("ReClash", defaults.title)
        assertEquals("STOP", defaults.stopText)
        assertEquals(false, defaults.onlyStatisticsProxy)
        assertEquals(emptyList<NotificationComponent>(), defaults.components)
        assertEquals("Protection active", defaults.activeText)
        assertEquals("Network", defaults.networkStateText)
        assertEquals("Current server", defaults.currentServerText)
        assertEquals("Unknown", defaults.networkUnknownText)
        assertEquals(true, defaults.showPauseAction)
        assertEquals(true, defaults.showStopAction)
        assertEquals(true, defaults.hideSensitiveOnLockScreen)
    }

    @Test
    fun `core events update notification status projections`() {
        ServiceConfig.resetCoreStatuses()
        ServiceConfig.acceptCoreEvent(
            """{"method":"message","arguments":[{"type":"rcxStatus","data":{"enabled":true,"mode":"auto","terrain":"portal","node":"edge","delay":42,"searching":false}},{"type":"doctorStatus","data":{"revision":7,"state":"complete","health":"degraded","confidence":"probable","causeCode":"timeout"}}]}""",
        )

        assertEquals(true, ServiceConfig.smartRoutingStatus.value.enabled)
        assertEquals("edge", ServiceConfig.smartRoutingStatus.value.node)
        assertEquals(42, ServiceConfig.smartRoutingStatus.value.delay)
        assertEquals("portal", ServiceConfig.smartRoutingStatus.value.terrain)
        assertEquals("auto", ServiceConfig.smartRoutingStatus.value.mode)
        assertEquals(7L, ServiceConfig.doctorStatus.value.revision)
        assertEquals("degraded", ServiceConfig.doctorStatus.value.health)
        assertEquals("timeout", ServiceConfig.doctorStatus.value.causeCode)
    }

    @Test
    fun `core event projection ignores stale doctor revisions and malformed data`() {
        ServiceConfig.resetCoreStatuses()
        ServiceConfig.acceptCoreEvent(
            """{"method":"message","arguments":[{"type":"doctorStatus","data":{"revision":9,"health":"broken"}}]}""",
        )
        ServiceConfig.acceptCoreEvent(
            """{"method":"message","arguments":[{"type":"doctorStatus","data":{"revision":8,"health":"healthy"}}]}""",
        )
        ServiceConfig.acceptCoreEvent("not json")

        assertEquals(9L, ServiceConfig.doctorStatus.value.revision)
        assertEquals("broken", ServiceConfig.doctorStatus.value.health)
    }

    @Test
    fun `core event projection ignores primitive data without losing later statuses`() {
        ServiceConfig.resetCoreStatuses()

        ServiceConfig.acceptCoreEvent(
            """{"method":"message","arguments":[{"type":"loaded","data":"provider"},{"type":"doctorStatus","data":{"revision":10,"health":"degraded"}}]}""",
        )

        assertEquals(10L, ServiceConfig.doctorStatus.value.revision)
        assertEquals("degraded", ServiceConfig.doctorStatus.value.health)
    }

    @Test
    fun `reset core statuses clears every notification projection`() {
        ServiceConfig.acceptCoreEvent(
            """{"method":"message","arguments":[{"type":"rcxStatus","data":{"enabled":true,"node":"edge","delay":42,"searching":true}},{"type":"doctorStatus","data":{"revision":7,"state":"complete","health":"degraded","confidence":"probable","causeCode":"timeout"}}]}""",
        )

        ServiceConfig.resetCoreStatuses()

        assertEquals(SmartRoutingStatus(), ServiceConfig.smartRoutingStatus.value)
        assertEquals(DoctorStatus(), ServiceConfig.doctorStatus.value)
    }

    @Test
    fun `active server parser consumes canonical compact object`() {
        assertEquals(
            "edge",
            parseActiveServer("""{"group":"GLOBAL","name":"edge"}""", "GLOBAL"),
        )
        assertEquals(null, parseActiveServer("null", "GLOBAL"))
    }

    @Test
    fun `notification projection follows exact component order and options`() {
        val routing = SmartRoutingStatus(
            enabled = true,
            node = "edge",
            delay = 42,
            terrain = "whitelist",
        )
        val params = NotificationParams(
            components = listOf(
                NotificationComponent(type = "currentServer"),
                NotificationComponent(type = "networkState"),
                NotificationComponent(type = "connectionDoctor", doctorPriority = "always"),
                NotificationComponent(type = "smartRouting"),
                NotificationComponent(type = "speed", hideWhenIdle = false),
                NotificationComponent(type = "sessionTraffic"),
            ),
        )

        assertEquals(
            "Current server · Amsterdam\nNetwork · Whitelist\n" +
                "Connection Doctor · Connection healthy\nSmart Routing · edge · 42ms\n" +
                "0B/s↑\nSession traffic · 3MB↑",
            params.projectContent(
                routing = routing,
                doctor = DoctorStatus(health = "healthy"),
                activeServer = "Amsterdam",
                traffic = "0B/s↑",
                trafficIdle = true,
                sessionTraffic = "3MB↑",
            ),
        )
    }

    @Test
    fun `notification projection skips unavailable values and falls back`() {
        val params = NotificationParams(
            components = listOf(
                NotificationComponent(type = "currentServer"),
                NotificationComponent(type = "speed"),
                NotificationComponent(type = "sessionTraffic"),
            ),
        )

        assertEquals(
            "Protection active",
            params.projectContent(
                routing = SmartRoutingStatus(),
                doctor = DoctorStatus(),
                activeServer = null,
                traffic = "0B/s↑",
                trafficIdle = true,
                sessionTraffic = null,
            ),
        )
    }

    @Test
    fun `network projection localizes known and future terrain`() {
        val params = NotificationParams(
            components = listOf(NotificationComponent(type = "networkState")),
        )

        assertEquals(
            "Network · Captive portal",
            params.projectContent(
                routing = SmartRoutingStatus(enabled = true, terrain = "portal"),
                doctor = DoctorStatus(),
                activeServer = null,
                traffic = null,
                trafficIdle = true,
                sessionTraffic = null,
            ),
        )
        assertEquals(
            "Network · Unknown",
            params.projectContent(
                routing = SmartRoutingStatus(enabled = true, terrain = "satellite"),
                doctor = DoctorStatus(),
                activeServer = null,
                traffic = null,
                trafficIdle = true,
                sessionTraffic = null,
            ),
        )
    }

    @Test
    fun `notification projection redacts content and actions behind the keyguard`() {
        val params = NotificationParams(
            title = "Private profile",
            showPauseAction = true,
            showStopAction = true,
        )

        val projected = params.extended(
            paused = false,
            routing = SmartRoutingStatus(enabled = true, node = "edge"),
            doctor = DoctorStatus(health = "broken"),
            locked = true,
        )

        assertEquals("ReClash", projected.title)
        assertEquals("Protection active", projected.contentText)
        assertEquals(false, projected.showPauseAction)
        assertEquals(false, projected.showStopAction)
    }

    @Test
    fun `privacy and paused overrides do not resolve current server`() {
        var resolverCalls = 0
        val params = NotificationParams(
            components = listOf(NotificationComponent(type = "currentServer", group = "GLOBAL")),
        )
        val resolver = {
            resolverCalls++
            "edge"
        }

        params.extended(
            paused = false,
            routing = SmartRoutingStatus(),
            doctor = DoctorStatus(),
            activeServerResolver = resolver,
            locked = true,
        )
        params.extended(
            paused = true,
            routing = SmartRoutingStatus(),
            doctor = DoctorStatus(),
            activeServerResolver = resolver,
        )

        assertEquals(0, resolverCalls)
    }

    @Test
    fun `notification projection keeps configured content while privacy is disabled`() {
        val params = NotificationParams(
            title = "Visible profile",
            hideSensitiveOnLockScreen = false,
            showPauseAction = true,
            showStopAction = true,
        )

        val projected = params.extended(
            paused = true,
            routing = SmartRoutingStatus(),
            doctor = DoctorStatus(),
            locked = true,
        )

        assertEquals("Visible profile", projected.title)
        assertEquals("Paused", projected.contentText)
        assertEquals(true, projected.showPauseAction)
        assertEquals(true, projected.showStopAction)
    }

    @Test
    fun `each visibility posts to a channel of its own`() {
        assertEquals(
            listOf("ReClash", "ReClash.quiet", "ReClash.off"),
            listOf("detailed", "minimal", "off")
                .map { NotificationParams(visibility = it).channelId },
        )
    }

    @Test
    fun `an unknown visibility stays on the audible channel`() {
        assertEquals(
            GlobalState.NOTIFICATION_CHANNEL,
            NotificationParams(visibility = "quiet").channelId,
        )
    }

    @Test
    fun `the keyguard projection keeps the channel of its level`() {
        val projected = NotificationParams(visibility = "off").extended(
            paused = false,
            routing = SmartRoutingStatus(),
            doctor = DoctorStatus(),
            locked = true,
        )

        assertEquals(GlobalState.NOTIFICATION_CHANNEL_HIDDEN, projected.channelId)
    }

    @Test
    fun `only live counters ask the notification for a ticker`() {
        assertEquals(false, NotificationParams().needsTicker)
        assertEquals(
            false,
            NotificationParams(
                components = listOf(NotificationComponent(type = "networkState")),
            ).needsTicker,
        )
        assertEquals(
            true,
            NotificationParams(
                components = listOf(
                    NotificationComponent(type = "networkState"),
                    NotificationComponent(type = "speed"),
                ),
            ).needsTicker,
        )
        assertEquals(
            true,
            NotificationParams(
                components = listOf(NotificationComponent(type = "sessionTraffic")),
            ).needsTicker,
        )
    }

    @Test
    fun `updateVpnOptions publishes the latest options`() {
        ServiceConfig.updateVpnOptions(vpnOptions(7890))
        assertEquals(7890, ServiceConfig.vpnOptions?.port)

        val latest = vpnOptions(7891)
        ServiceConfig.updateVpnOptions(latest)

        assertSame(latest, ServiceConfig.vpnOptions)
    }

    @Test
    fun `updateNotificationParams emits through the state flow`() = runTest {
        val params = NotificationParams(
            title = "Profile",
            stopText = "Halt",
            onlyStatisticsProxy = true,
        )

        ServiceConfig.updateNotificationParams(params)

        assertSame(params, ServiceConfig.notificationParams.value)
    }

    @Test
    fun `notification params state flow keeps the newest value`() = runTest {
        val first = NotificationParams(title = "first")
        val second = NotificationParams(title = "second")

        ServiceConfig.updateNotificationParams(first)
        ServiceConfig.updateNotificationParams(second)

        assertSame(second, ServiceConfig.notificationParams.value)
        assertNotSame(first, ServiceConfig.notificationParams.value)
    }
}
