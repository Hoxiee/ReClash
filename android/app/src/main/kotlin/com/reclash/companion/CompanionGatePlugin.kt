package com.reclash.companion

import com.reclash.common.GlobalState
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

// Temporary Slice 0 surface: lets an on-device run trigger the GATE C/D self-test over a method
// channel. TODO: companion-gate-plugin removal once real capabilities replace the gate harness.
class CompanionGatePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler(this@CompanionGatePlugin)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "runGate" -> {
                val context = GlobalState.application
                GlobalState.launch {
                    val outcome = withContext(Dispatchers.IO) {
                        CompanionGateRunner(context).run()
                    }
                    withContext(Dispatchers.Main) { result.success(outcome) }
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        private const val CHANNEL = "com.reclash/companion_gate"
    }
}
