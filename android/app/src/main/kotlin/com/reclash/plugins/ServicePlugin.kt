package com.reclash.plugins

import android.content.Context
import com.reclash.ServiceController
import com.reclash.ServiceState
import com.reclash.common.Components
import com.reclash.models.SharedState
import com.reclash.service.ServiceConfig
import com.reclash.widgets.WidgetStore
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var scope: CoroutineScope
    private val gson = Gson()
    private val widgetDeliveryInFlight = AtomicBoolean()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        widgetDeliveryInFlight.set(false)
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "${Components.PACKAGE_NAME}/service")
        channel.setMethodCallHandler(this)
        // The service pauses itself natively; Flutter only projects that state.
        scope.launch {
            ServiceConfig.pauseState.collect { state ->
                sendPauseState(state.paused)
            }
        }
        scope.launch {
            WidgetStore.selectionRecorded.collect { sendWidgetSelections() }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
        ServiceController.setEventListener(null)
    }

    override fun onMethodCall(call: MethodCall, rawResult: MethodChannel.Result) {
        // Most handlers below reply from a scope worker on Dispatchers.Default,
        // but a MethodChannel.Result has to be answered on the platform thread.
        // Wrapping once here covers every branch, including notImplemented.
        val result = MainThreadResult(rawResult)
        when (call.method) {
            "init" -> initialize(result)
            "shutdown" -> shutdown(result)
            "invokeMethod" -> invokeMethod(call, result)
            "getRunTime" -> getRunTime(result)
            "syncState" -> syncState(call, result)
            "start" -> start(result)
            "stop" -> stop(result)
            "pause" -> pause(result)
            "resume" -> resume(result)
            "getPauseState" -> result.success(ServiceConfig.pauseState.value.paused)
            "peekWidgetSelections" -> result.success(widgetSelections())
            "ackWidgetSelections" -> acknowledgeWidgetSelections(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(result: MethodChannel.Result) {
        ServiceController.setEventListener(::sendEvent)
            .onSuccess { result.success("") }
            .onFailure { error -> result.success(error.message.orEmpty()) }
    }

    private fun shutdown(result: MethodChannel.Result) {
        scope.launch {
            ServiceController.unbind()
            result.success(true)
        }
    }

    private fun invokeMethod(call: MethodCall, result: MethodChannel.Result) {
        val data = call.arguments as? String
        if (data == null) {
            result.error("INVALID_ARGUMENT", "Method call payload must be a string", null)
            return
        }
        scope.launch {
            ServiceController.invokeMethod(data) { response ->
                result.success(response)
            }.onFailure { error ->
                result.error("CORE_ERROR", error.message, null)
            }
        }
    }

    private fun getRunTime(result: MethodChannel.Result) {
        scope.launch {
            result.success(ServiceState.refresh())
        }
    }

    private fun syncState(call: MethodCall, result: MethodChannel.Result) {
        val data = call.arguments as? String
        val state = runCatching {
            gson.fromJson(data, SharedState::class.java)
        }.getOrNull()
        if (state == null) {
            result.success("Invalid shared state")
            return
        }
        scope.launch {
            ServiceState.syncSharedState(state)
            result.success("")
        }
    }

    private fun start(result: MethodChannel.Result) {
        ServiceState.requestStart()
        result.success(true)
    }

    private fun stop(result: MethodChannel.Result) {
        ServiceState.requestStop()
        result.success(true)
    }

    private fun pause(result: MethodChannel.Result) {
        ServiceState.requestPause()
        result.success(true)
    }

    private fun resume(result: MethodChannel.Result) {
        ServiceState.requestResume()
        result.success(true)
    }

    private fun sendEvent(value: String?) {
        scope.launch(Dispatchers.Main) {
            channel.invokeMethod("event", value)
        }
    }

    private fun sendWidgetSelections() {
        if (!widgetDeliveryInFlight.compareAndSet(false, true)) return
        val payload = widgetSelections()
        if (payload == null) {
            widgetDeliveryInFlight.set(false)
            return
        }
        scope.launch(Dispatchers.Main) {
            channel.invokeMethod(
                "widgetSelections",
                payload,
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        if (result == true) {
                            acknowledgeWidgetSelections(payload.getValue("token") as String)
                        }
                        widgetDeliveryInFlight.set(false)
                        if (result == true) sendWidgetSelections()
                    }

                    override fun error(code: String, message: String?, details: Any?) {
                        widgetDeliveryInFlight.set(false)
                    }

                    override fun notImplemented() {
                        widgetDeliveryInFlight.set(false)
                    }
                },
            )
        }
    }

    private fun widgetSelections(): Map<String, Any>? =
        WidgetStore.peekSelections(context)?.let { batch ->
            mapOf(
                "token" to batch.token,
                "selections" to batch.selections,
            )
        }

    private fun acknowledgeWidgetSelections(call: MethodCall, result: MethodChannel.Result) {
        val token = call.arguments as? String
        result.success(token != null && acknowledgeWidgetSelections(token))
    }

    private fun acknowledgeWidgetSelections(token: String): Boolean =
        WidgetStore.acknowledgeSelections(context, token)

    private fun sendPauseState(paused: Boolean) {
        scope.launch(Dispatchers.Main) {
            channel.invokeMethod("pauseState", paused)
        }
    }
}
