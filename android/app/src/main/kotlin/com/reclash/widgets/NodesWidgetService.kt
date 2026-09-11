package com.reclash.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.reclash.ServiceState
import kotlinx.coroutines.runBlocking

class NodesWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        NodesWidgetFactory(applicationContext, intent)
}

// onDataSetChanged runs on a binder thread the framework expects to block, so
// the core call happens here rather than behind a stale cache.
private class NodesWidgetFactory(
    private val context: Context,
    intent: Intent,
) : RemoteViewsService.RemoteViewsFactory {
    private val appWidgetId = intent.getIntExtra(
        AppWidgetManager.EXTRA_APPWIDGET_ID,
        AppWidgetManager.INVALID_APPWIDGET_ID,
    )
    private var group = ""
    private var selected = ""
    private var nodes = emptyList<WidgetNode>()

    override fun onCreate() = Unit

    override fun onDataSetChanged() {
        val snapshot = WidgetSnapshots.current(context)
        val view = runBlocking {
            if (ServiceState.refresh() == 0L) null else ProxyCatalog.group(snapshot.group)
        }
        group = view?.name.orEmpty()
        selected = view?.now.orEmpty()
        val manager = runCatching { AppWidgetManager.getInstance(context) }.getOrNull()
        val rows = manager?.nodesBox(appWidgetId)?.nodeRows ?: 1
        nodes = view?.nodes?.take(rows).orEmpty()
    }

    override fun onDestroy() {
        nodes = emptyList()
    }

    override fun getCount(): Int = nodes.size

    override fun getViewAt(position: Int): RemoteViews? = nodes.getOrNull(position)?.let { node ->
        WidgetRenderer.nodeRow(context, node, node.name == selected, group)
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long =
        nodes.getOrNull(position)?.name?.hashCode()?.toLong() ?: position.toLong()

    override fun hasStableIds(): Boolean = true
}
