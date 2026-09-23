package com.reclash.companion

import com.reclash.common.GlobalState
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

// TV-facing method channel over the retained engine. Enable/pair/approve/revoke run on the single
// isolate; the phone never reaches these — they gate on a local TV user action only.
class CompanionReceiverPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler(this@CompanionReceiverPlugin)
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
        val context = GlobalState.application
        val receiver = CompanionReceiver.get(context)
        when (call.method) {
            "enable" -> {
                // Bind the listener first, then raise the FGS only on success. startForegroundService
                // arms a 5s startForeground deadline that onStartCommand (same main thread) cannot meet
                // while enable() does its TLS setup, and a stop() on the error path races the same call.
                when (val outcome = receiver.enable()) {
                    is CompanionEnableResult.Running -> {
                        CompanionService.start(context)
                        result.success(
                            mapOf(
                                "deviceId" to outcome.deviceId,
                                "host" to outcome.host,
                                "port" to outcome.port,
                            ),
                        )
                    }
                    is CompanionEnableResult.Error -> result.error(outcome.reason, null, null)
                }
            }
            "disable" -> {
                receiver.disable()
                CompanionService.stop(context)
                result.success(null)
            }
            "isRunning" -> result.success(receiver.isRunning())
            "openPairingWindow" -> result.success(receiver.openPairingWindow())
            "cancelPairingWindow" -> {
                receiver.cancelPairingWindow()
                result.success(null)
            }
            "pendingPairing" -> result.success(receiver.pendingPairing())
            "approvePending" -> result.success(receiver.approvePending())
            "rejectPending" -> {
                receiver.rejectPending()
                result.success(null)
            }
            "trustedClients" -> result.success(receiver.trustedClients())
            "revokeClient" -> {
                val clientId = call.argument<String>("clientId")
                if (clientId == null) {
                    result.error("invalidInput", null, null)
                } else {
                    result.success(receiver.revokeClient(clientId))
                }
            }
            "resetIdentity" -> {
                receiver.resetIdentity()
                CompanionService.stop(context)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        private const val CHANNEL = "com.reclash/companion_receiver"
    }
}
