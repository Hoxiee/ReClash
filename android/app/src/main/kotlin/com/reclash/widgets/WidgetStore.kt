package com.reclash.widgets

import android.content.Context
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.UUID
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow

private data class StoredWidgetSelections(
    val token: String,
    val selections: Map<String, String>,
)

private val selectionMapType = object : TypeToken<Map<String, String>>() {}.type

internal data class WidgetSelectionBatch(
    val token: String,
    val selections: Map<String, String>,
)

internal class WidgetSelectionLedger(
    private val read: () -> String?,
    private val write: (String?) -> Boolean,
    private val nextToken: () -> String = { UUID.randomUUID().toString() },
) {
    private val gson = Gson()

    fun peek(): WidgetSelectionBatch? {
        val raw = read() ?: return null
        return decode(raw).takeIf { it.selections.isNotEmpty() }
    }

    fun record(group: String, node: String): Boolean {
        val selections = peek()?.selections.orEmpty().toMutableMap()
        selections[group] = node
        return write(encode(WidgetSelectionBatch(nextToken(), selections)))
    }

    fun acknowledge(token: String): Boolean {
        val pending = peek() ?: return false
        return pending.token == token && write(null)
    }

    private fun decode(raw: String): WidgetSelectionBatch = runCatching {
        val stored = gson.fromJson(raw, StoredWidgetSelections::class.java)
        require(stored.token.isNotBlank())
        WidgetSelectionBatch(
            token = stored.token,
            selections = stored.selections.filterValues { it.isNotBlank() },
        )
    }.recoverCatching {
        val selections = gson.fromJson<Map<String, String>>(raw, selectionMapType)
        WidgetSelectionBatch(
            token = "legacy",
            selections = selections.filterValues { it.isNotBlank() },
        )
    }.getOrDefault(WidgetSelectionBatch("invalid", emptyMap()))

    private fun encode(batch: WidgetSelectionBatch): String =
        gson.toJson(StoredWidgetSelections(batch.token, batch.selections))
}

// A widget outlives the process that drew it, so only durable facts.
internal object WidgetStore {
    private const val storeName = "reclash_widgets"
    private const val keyProfile = "profile"
    private const val keyGroup = "group"
    private const val keyNode = "node"
    private const val keyDelay = "delay"
    private const val keyTerrain = "terrain"
    private const val keySelections = "pending_selections"

    private val recorded = MutableSharedFlow<Unit>(extraBufferCapacity = 1)

    // The core takes the tap at once; the profile owning it may be asleep.
    val selectionRecorded: SharedFlow<Unit> = recorded.asSharedFlow()

    private fun preferences(context: Context) =
        context.getSharedPreferences(storeName, Context.MODE_PRIVATE)

    fun load(context: Context): WidgetSnapshot = runCatching {
        val preferences = preferences(context)
        WidgetSnapshot(
            profile = preferences.getString(keyProfile, "").orEmpty(),
            group = preferences.getString(keyGroup, "").orEmpty(),
            node = preferences.getString(keyNode, "").orEmpty(),
            delay = preferences.getInt(keyDelay, 0),
            terrain = preferences.getString(keyTerrain, "").orEmpty(),
        )
    }.getOrDefault(WidgetSnapshot())

    fun save(context: Context, snapshot: WidgetSnapshot) {
        runCatching {
            preferences(context).edit()
                .putString(keyProfile, snapshot.profile)
                .putString(keyGroup, snapshot.group)
                .putString(keyNode, snapshot.node)
                .putInt(keyDelay, snapshot.delay)
                .putString(keyTerrain, snapshot.terrain)
                .apply()
        }
    }

    @Synchronized
    fun recordSelection(context: Context, group: String, node: String) {
        if (ledger(context).record(group, node)) {
            recorded.tryEmit(Unit)
        }
    }

    @Synchronized
    fun peekSelections(context: Context): WidgetSelectionBatch? = ledger(context).peek()

    @Synchronized
    fun acknowledgeSelections(context: Context, token: String): Boolean =
        ledger(context).acknowledge(token)

    private fun ledger(context: Context): WidgetSelectionLedger {
        val preferences = preferences(context)
        return WidgetSelectionLedger(
            read = { preferences.getString(keySelections, null) },
            write = { value ->
                val editor = preferences.edit()
                if (value == null) editor.remove(keySelections) else editor.putString(keySelections, value)
                editor.commit()
            },
        )
    }
}
