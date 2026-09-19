package com.reclash.widgets

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.reclash.RunState
import com.reclash.ServiceState
import com.reclash.common.GlobalState
import com.reclash.sharedState
import kotlinx.coroutines.launch

class WidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val name = intent.action?.substringAfterLast('.') ?: return
        val group = intent.getStringExtra(WidgetActions.EXTRA_GROUP).orEmpty()
        val node = intent.getStringExtra(WidgetActions.EXTRA_NODE).orEmpty()
        val enabled = intent.getBooleanExtra(WidgetActions.EXTRA_ENABLED, false)
        val application = context.applicationContext
        // The broadcast returns long before the core answers, and a widget tap
        // is the only thing holding this process up.
        val pending = goAsync()
        GlobalState.launch {
            try {
                dispatch(application, name, group, node, enabled)
            } finally {
                pending.finish()
            }
        }
    }

    private suspend fun dispatch(
        context: Context,
        name: String,
        group: String,
        node: String,
        enabled: Boolean,
    ) {
        if (ServiceState.refresh() == 0L) {
            WidgetPump.wake(context)
            return
        }
        when (name) {
            WidgetActions.EXAMINE -> ProxyCatalog.examine()
            WidgetActions.MEASURE -> measure(context, group)
            WidgetActions.SELECT -> select(context, group, node)
            WidgetActions.AUTOPILOT -> ProxyCatalog.setAutopilot(enabled)
            else -> return
        }
        WidgetPump.wake(context)
    }

    private suspend fun measure(context: Context, preferred: String) {
        val shared = runCatching { GlobalState.application.sharedState }.getOrNull()
        val target = preferred.takeIf { it.isNotBlank() }
            ?: shared?.activeServerGroup
        val view = ProxyCatalog.group(target) ?: return
        ProxyCatalog.measure(view.nodes.map { it.name }, shared?.setupParams?.testUrl.orEmpty())
        NodesWidgetProvider.notifyRows(context)
    }

    private suspend fun select(context: Context, group: String, node: String) {
        if (group.isBlank() || node.isBlank()) return
        if (ServiceState.runState.value == RunState.STOPPED) return
        if (!ProxyCatalog.select(group, node)) return
        WidgetStore.recordSelection(context, group, node)
        NodesWidgetProvider.notifyRows(context)
    }
}
