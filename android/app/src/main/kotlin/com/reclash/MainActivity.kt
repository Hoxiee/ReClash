package com.reclash

import android.os.Bundle
import com.reclash.companion.CompanionClientPlugin
import com.reclash.companion.CompanionGatePlugin
import com.reclash.companion.CompanionReceiverPlugin
import com.reclash.plugins.AppPlugin
import com.reclash.plugins.ServicePlugin
import com.reclash.plugins.TilePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        if (application.sharedState.pureBlackTheme && isNightMode(resources.configuration)) {
            setTheme(R.style.LaunchThemeAmoled)
        }
        super.onCreate(savedInstanceState)
    }

    // GATE B: reuse the one cached engine (null first launch) so the isolate outlives the Activity (I03).
    override fun provideFlutterEngine(context: android.content.Context): FlutterEngine? =
        FlutterEngineCache.getInstance().get(ENGINE_ID)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (FlutterEngineCache.getInstance().get(ENGINE_ID) == null) {
            FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine)
            flutterEngine.plugins.add(AppPlugin())
            flutterEngine.plugins.add(ServicePlugin())
            flutterEngine.plugins.add(TilePlugin())
            flutterEngine.plugins.add(CompanionGatePlugin())
            flutterEngine.plugins.add(CompanionReceiverPlugin())
            flutterEngine.plugins.add(CompanionClientPlugin())
        }
        ServiceState.attachFlutterEngine(flutterEngine)
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {}

    companion object {
        const val ENGINE_ID = "reclash_main_engine"
    }
}
