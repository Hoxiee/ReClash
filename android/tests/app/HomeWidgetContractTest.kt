package com.reclash

import java.io.File
import org.junit.Assert.assertTrue
import org.junit.Test

class HomeWidgetContractTest {
    private val sourceRoot = File("src/main")

    @Test
    fun `manifest registers the home widget provider`() {
        val manifest = sourceRoot.resolve("AndroidManifest.xml").readText()

        assertTrue(manifest.contains("android:name=\".HomeWidgetProvider\""))
        assertTrue(manifest.contains("android.appwidget.action.APPWIDGET_UPDATE"))
        assertTrue(manifest.contains("android:resource=\"@xml/home_widget_info\""))
    }

    @Test
    fun `widget resources expose the rendered controls`() {
        val layout = sourceRoot.resolve("res/layout/home_widget.xml").readText()
        val info = sourceRoot.resolve("res/xml/home_widget_info.xml").readText()

        assertTrue(layout.contains("android:id=\"@+id/widget_root\""))
        assertTrue(layout.contains("android:id=\"@+id/widget_status\""))
        assertTrue(layout.contains("android:id=\"@+id/widget_action\""))
        assertTrue(info.contains("android:initialLayout=\"@layout/home_widget\""))
        assertTrue(info.contains("android:updatePeriodMillis=\"0\""))
    }

    @Test
    fun `provider refreshes before rendering and delegates clicks`() {
        val provider = sourceRoot
            .resolve("kotlin/com/reclash/HomeWidgetProvider.kt")
            .readText()

        assertTrue(provider.indexOf("ServiceState.refresh()") < provider.indexOf("update("))
        assertTrue(provider.contains("presentation.action.quickIntent.toPendingIntent"))
        assertTrue(!provider.contains("ServiceState.handle"))
    }
}
