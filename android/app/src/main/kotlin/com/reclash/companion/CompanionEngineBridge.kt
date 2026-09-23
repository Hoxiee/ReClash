package com.reclash.companion

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

// Bridges a NanoHTTPD worker thread to the retained Dart engine (§11/§12). The isolate answers on
// the main looper, so the request thread blocks on a latch with a bounded timeout: a Dart handler
// that never replies reports unreachable rather than hanging a connection open (I14).
internal open class CompanionEngineBridge(
    private val engineId: String = ENGINE_ID,
    private val channelName: String = CHANNEL,
    private val timeoutMs: Long = DEFAULT_TIMEOUT_MS,
) {
    open fun call(method: String, arguments: Any?): CompanionBridgeResult {
        val engine = FlutterEngineCache.getInstance().get(engineId)
            ?: return CompanionBridgeResult.Unreachable
        val latch = CountDownLatch(1)
        val outcome = arrayOfNulls<CompanionBridgeResult>(1)
        Handler(Looper.getMainLooper()).post {
            MethodChannel(engine.dartExecutor.binaryMessenger, channelName).invokeMethod(
                method,
                arguments,
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        outcome[0] = CompanionBridgeResult.Ok(result)
                        latch.countDown()
                    }

                    override fun error(code: String, message: String?, details: Any?) {
                        outcome[0] = CompanionBridgeResult.Failed(code)
                        latch.countDown()
                    }

                    override fun notImplemented() {
                        outcome[0] = CompanionBridgeResult.Unreachable
                        latch.countDown()
                    }
                },
            )
        }
        return if (latch.await(timeoutMs, TimeUnit.MILLISECONDS)) {
            outcome[0] ?: CompanionBridgeResult.Unreachable
        } else {
            CompanionBridgeResult.Unreachable
        }
    }

    companion object {
        private const val ENGINE_ID = "reclash_main_engine"
        private const val CHANNEL = "com.reclash/companion_bridge"
        private const val DEFAULT_TIMEOUT_MS = 8_000L
    }
}

internal sealed class CompanionBridgeResult {
    data class Ok(val value: Any?) : CompanionBridgeResult()
    data class Failed(val code: String) : CompanionBridgeResult()
    object Unreachable : CompanionBridgeResult()
}
