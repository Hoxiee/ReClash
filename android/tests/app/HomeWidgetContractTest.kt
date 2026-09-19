package com.reclash

import java.io.File
import org.junit.Assert.assertTrue
import org.junit.Test

private val widgets = listOf(
    Triple(".HomeWidgetProvider", "home_widget", "home_widget_info"),
    Triple(".widgets.ControlWidgetProvider", "widget_control", "widget_control_info"),
    Triple(".widgets.NodesWidgetProvider", "widget_nodes", "widget_nodes_info"),
)

class HomeWidgetContractTest {
    private val sourceRoot = File("src/main")

    @Test
    fun `manifest registers every widget provider`() {
        val manifest = sourceRoot.resolve("AndroidManifest.xml").readText()

        widgets.forEach { (provider, _, info) ->
            assertTrue(manifest.contains("android:name=\"$provider\""))
            assertTrue(manifest.contains("android:resource=\"@xml/$info\""))
        }
        assertTrue(manifest.contains("android.appwidget.action.APPWIDGET_UPDATE"))
    }

    @Test
    fun `quick actions and crash collection stay private by default`() {
        val manifest = sourceRoot.resolve("AndroidManifest.xml").readText()
        val quickAction = manifest.substringAfter("android:name=\".QuickActionActivity\"")
            .substringBefore("/>")
        val crashlytics = manifest
            .substringAfter("android:name=\"firebase_crashlytics_collection_enabled\"")
            .substringBefore("/>")

        assertTrue(quickAction.contains("android:exported=\"false\""))
        assertTrue(crashlytics.contains("android:value=\"false\""))
    }

    @Test
    fun `the collection widget binds a permission guarded service`() {
        val manifest = sourceRoot.resolve("AndroidManifest.xml").readText()
        val service = manifest.substringAfter("android:name=\".widgets.NodesWidgetService\"")
            .substringBefore("/>")

        assertTrue(service.contains("android:permission=\"android.permission.BIND_REMOTEVIEWS\""))
        assertTrue(service.contains("android:exported=\"false\""))
        assertTrue(manifest.contains("android:name=\".widgets.WidgetActionReceiver\""))
    }

    @Test
    fun `every descriptor resizes and leaves the clock to the app`() {
        widgets.forEach { (_, layout, info) ->
            val descriptor = sourceRoot.resolve("res/xml/$info.xml").readText()

            assertTrue(descriptor.contains("android:initialLayout=\"@layout/$layout\""))
            assertTrue(descriptor.contains("android:updatePeriodMillis=\"0\""))
            assertTrue(descriptor.contains("android:resizeMode="))
            assertTrue(descriptor.contains("android:minResizeWidth="))
            assertTrue(descriptor.contains("android:description="))
        }
    }

    @Test
    fun `widget resources expose the rendered controls`() {
        val layout = sourceRoot.resolve("res/layout/home_widget.xml").readText()
        val nodes = sourceRoot.resolve("res/layout/widget_nodes.xml").readText()

        assertTrue(layout.contains("android:id=\"@+id/widget_root\""))
        assertTrue(layout.contains("android:id=\"@+id/widget_status\""))
        assertTrue(layout.contains("android:id=\"@+id/widget_action\""))
        assertTrue(nodes.contains("android:id=\"@+id/widget_list\""))
        assertTrue(nodes.contains("android:id=\"@+id/widget_empty\""))
    }

    @Test
    fun `the pump refreshes before it renders and every provider defers to it`() {
        val pump = widgetSource("WidgetPump.kt")

        assertTrue(pump.indexOf("ServiceState.refresh()") < pump.indexOf("render(application)"))
        widgets.forEach { (provider, _, _) ->
            val name = provider.substringAfterLast('.')
            assertTrue(pump.contains("$name.updateAll("))
        }
    }

    @Test
    fun `the power button reuses the switch widget presentation`() {
        val actions = widgetSource("WidgetActions.kt")
        val provider = sourceRoot
            .resolve("kotlin/com/reclash/HomeWidgetProvider.kt")
            .readText()

        assertTrue(
            actions.contains("toHomeWidgetPresentation().action.quickIntent.toPendingIntent"),
        )
        assertTrue(provider.contains("class HomeWidgetProvider : PumpWidgetProvider()"))
        assertTrue(!provider.contains("ServiceState.handle"))
    }

    private fun widgetSource(name: String): String =
        sourceRoot.resolve("kotlin/com/reclash/widgets/$name").readText()
}
