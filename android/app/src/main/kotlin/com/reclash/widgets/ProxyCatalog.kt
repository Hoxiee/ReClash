package com.reclash.widgets

import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.google.gson.JsonPrimitive
import com.reclash.ServiceController
import java.util.concurrent.atomic.AtomicLong
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.coroutines.resume

internal data class WidgetNode(val name: String, val delay: Int)

internal data class WidgetGroupView(
    val name: String,
    val now: String,
    val nodes: List<WidgetNode>,
)

private val selectableGroupTypes = setOf(
    "Selector",
    "URLTest",
    "Fallback",
    "LoadBalance",
    "Relay",
)

private const val rcxNodeGroup = "RCX-NODE"

private const val rcxGroupPrefix = "RCX-"

internal fun unwrapCoreResult(raw: String?): JsonElement? {
    val root = runCatching { JsonParser.parseString(raw).asJsonObject }.getOrNull() ?: return null
    val error = root.get("error")
    if (error != null && !error.isJsonNull) return null
    return root.get("result")?.takeUnless { it.isJsonNull }
}

internal fun parseWidgetGroups(result: JsonElement?): List<WidgetGroupView> {
    val root = result?.takeIf { it.isJsonObject }?.asJsonObject ?: return emptyList()
    val proxies = root.getAsJsonObject("proxies") ?: return emptyList()
    val all = root.getAsJsonArray("all") ?: return emptyList()
    return all.mapNotNull { entry ->
        val name = entry.takeIf { it.isJsonPrimitive }?.asString ?: return@mapNotNull null
        // The core refuses changeProxy on its own routing scaffolding, so a
        // group nobody can pick from must never reach the list.
        if (name.startsWith(rcxGroupPrefix) && name != rcxNodeGroup) return@mapNotNull null
        val raw = proxies.get(name)?.takeIf { it.isJsonObject }?.asJsonObject
            ?: return@mapNotNull null
        val type = raw.get("type")?.takeIf { it.isJsonPrimitive }?.asString
        if (type !in selectableGroupTypes) return@mapNotNull null
        val members = raw.getAsJsonArray("all") ?: return@mapNotNull null
        WidgetGroupView(
            name = name,
            now = raw.get("now")?.takeIf { it.isJsonPrimitive }?.asString.orEmpty(),
            nodes = members.mapNotNull { member ->
                val node = member.takeIf { it.isJsonPrimitive }?.asString
                    ?: return@mapNotNull null
                WidgetNode(node, lastDelayOf(proxies.get(node)))
            },
        )
    }
}

internal fun pickWidgetGroup(
    groups: List<WidgetGroupView>,
    preferred: String?,
): WidgetGroupView? {
    if (groups.isEmpty()) return null
    preferred?.takeIf { it.isNotBlank() }?.let { name ->
        groups.firstOrNull { it.name == name }?.let { return it }
    }
    return groups.firstOrNull { it.name == rcxNodeGroup }
        ?: groups.firstOrNull { it.nodes.size > 1 }
        ?: groups.first()
}

private fun lastDelayOf(raw: JsonElement?): Int {
    val history = raw?.takeIf { it.isJsonObject }?.asJsonObject?.getAsJsonArray("history")
        ?: return 0
    val last = history.lastOrNull()?.takeIf { it.isJsonObject }?.asJsonObject ?: return 0
    return runCatching { last.get("delay")?.asInt ?: 0 }.getOrDefault(0)
}

internal object ProxyCatalog {
    private const val callTimeoutMillis = 5_000L
    private const val delayTimeoutMillis = 3_000L
    private const val delayBatch = 8
    private const val delayLimit = 120

    private val requestId = AtomicLong()

    suspend fun group(preferred: String?): WidgetGroupView? =
        pickWidgetGroup(parseWidgetGroups(invoke("getProxies")), preferred)

    suspend fun select(group: String, node: String): Boolean {
        val arguments = JsonObject().apply {
            addProperty("group-name", group)
            addProperty("proxy-name", node)
        }
        val result = invoke("changeProxy", arguments) ?: return false
        val message = runCatching { result.asString }.getOrDefault("")
        if (message.isNotBlank()) return false
        invoke("resetConnections")
        return true
    }

    suspend fun measure(nodes: List<String>, testUrl: String) {
        if (testUrl.isBlank()) return
        nodes.take(delayLimit).chunked(delayBatch).forEach { chunk ->
            coroutineScope {
                chunk.map { node -> async { measureOne(node, testUrl) } }.awaitAll()
            }
        }
    }

    suspend fun examine(): Boolean {
        val arguments = JsonObject().apply { addProperty("mode", "standard") }
        return invoke("doctorStart", arguments) != null
    }

    // rcxSetEnabled takes the bare bool the core registered it with, not an
    // object, so the argument is a primitive rather than a wrapper.
    suspend fun setAutopilot(enabled: Boolean): Boolean =
        invoke("rcxSetEnabled", JsonPrimitive(enabled)) != null

    private suspend fun measureOne(node: String, testUrl: String) {
        val arguments = JsonObject().apply {
            addProperty("proxy-name", node)
            addProperty("test-url", testUrl)
            addProperty("timeout", delayTimeoutMillis)
        }
        invoke("asyncTestDelay", arguments, delayTimeoutMillis + 2_000L)
    }

    private suspend fun invoke(
        method: String,
        arguments: JsonElement? = null,
        timeoutMillis: Long = callTimeoutMillis,
    ): JsonElement? {
        val request = JsonObject().apply {
            addProperty("id", "widget-${requestId.incrementAndGet()}")
            addProperty("method", method)
            arguments?.let { add("arguments", it) }
        }.toString()
        val raw = withTimeoutOrNull(timeoutMillis) {
            suspendCancellableCoroutine { continuation ->
                val dispatched = ServiceController.invokeMethod(request) { response ->
                    if (continuation.isActive) continuation.resume(response)
                }
                if (dispatched.isFailure && continuation.isActive) continuation.resume("")
            }
        }
        return unwrapCoreResult(raw)
    }
}
