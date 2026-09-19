package com.reclash.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import com.reclash.R
import com.reclash.RunState

private const val colorFilter = "setColorFilter"
private const val imageAlpha = "setImageAlpha"
private const val dimmed = 92
private const val opaque = 255
private const val separator = " · "

internal object WidgetRenderer {
    fun switchWidget(context: Context, snapshot: WidgetSnapshot, box: WidgetBox): RemoteViews {
        val power = WidgetActions.power(snapshot.runState)
        val views = RemoteViews(context.packageName, R.layout.home_widget)
        tint(context, views, snapshot)
        views.setTextViewText(R.id.widget_status, context.getText(snapshot.statusRes))
        views.setTextViewText(R.id.widget_action, context.getText(snapshot.powerLabelRes))
        views.setTextViewText(R.id.widget_detail, switchDetail(context, snapshot))
        uptime(views, R.id.widget_uptime, snapshot)

        val showsAction = box.width >= WidgetWidth.MEDIUM
        val showsUptime = box.width > WidgetWidth.TINY && snapshot.live
        val showsDetail = box.height > WidgetHeight.COMPACT && box.width > WidgetWidth.TINY
        views.setViewVisibility(R.id.widget_action, visibility(showsAction))
        views.setViewVisibility(R.id.widget_uptime, visibility(showsUptime))
        views.setViewVisibility(R.id.widget_detail, visibility(showsDetail))

        // Without the pill there is nothing else to press, so the body has to
        // carry the switch rather than the app.
        if (showsAction) {
            views.setOnClickPendingIntent(R.id.widget_action, power)
            views.setOnClickPendingIntent(R.id.widget_root, WidgetActions.open(context))
        } else {
            views.setOnClickPendingIntent(R.id.widget_root, power)
        }
        return views
    }

    fun control(context: Context, snapshot: WidgetSnapshot, box: WidgetBox): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_control)
        tint(context, views, snapshot)
        views.setTextViewText(R.id.widget_title, title(context, snapshot))
        views.setTextViewText(R.id.widget_subtitle, statusSubtitle(context, snapshot))
        views.setTextViewText(R.id.widget_pill, context.getText(snapshot.statusRes))
        views.setTextColor(R.id.widget_pill, context.getColor(snapshot.tone.colorRes))

        views.setInt(R.id.widget_down_dot, colorFilter, context.getColor(R.color.widget_chart_down))
        views.setInt(R.id.widget_up_dot, colorFilter, context.getColor(R.color.widget_chart_up))
        views.setTextViewText(R.id.widget_down_value, formatSpeed(snapshot.downSpeed))
        views.setTextViewText(R.id.widget_up_value, formatSpeed(snapshot.upSpeed))
        uptime(views, R.id.widget_uptime, snapshot)

        views.setTextViewText(R.id.widget_terrain, context.getText(snapshot.terrainRes))
        views.setTextViewText(R.id.widget_doctor, context.getText(snapshot.doctorRes))
        views.setTextColor(R.id.widget_doctor, context.getColor(snapshot.doctorToneRes))

        views.setViewVisibility(R.id.widget_metrics, visibility(box.metricsFit))
        views.setViewVisibility(R.id.widget_chips, visibility(box.chipsFit))

        views.setTextViewText(R.id.widget_power_label, context.getText(snapshot.powerLabelRes))
        views.setImageViewResource(R.id.widget_power_icon, snapshot.powerIconRes)
        views.setOnClickPendingIntent(R.id.widget_power, WidgetActions.power(snapshot.runState))
        views.setOnClickPendingIntent(R.id.widget_root, WidgetActions.open(context))
        return views
    }

    fun nodes(context: Context, snapshot: WidgetSnapshot, appWidgetId: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_nodes)
        views.setInt(R.id.widget_mark, colorFilter, context.getColor(snapshot.tone.colorRes))
        views.setTextViewText(R.id.widget_group, nodesTitle(context, snapshot))

        // Autopilot is the whole point of the group, so the toggle reads its own
        // state rather than borrowing the connection tone.
        val autoColor = if (snapshot.routingEnabled) {
            R.color.widget_tone_active
        } else {
            R.color.widget_on_surface_variant
        }
        views.setTextColor(R.id.widget_auto, context.getColor(autoColor))
        val autopilot = WidgetActions.autopilot(context, !snapshot.routingEnabled)
            .takeIf { snapshot.live }
        views.setOnClickPendingIntent(R.id.widget_auto, autopilot)
        views.setBoolean(R.id.widget_auto, "setEnabled", autopilot != null)

        views.setTextViewText(
            R.id.widget_empty,
            context.getText(
                if (snapshot.live) R.string.widget_no_nodes else R.string.widget_service_off,
            ),
        )
        views.setEmptyView(R.id.widget_list, R.id.widget_empty)
        // A per-widget data URI is what keeps two placements from sharing one
        // factory, and therefore one group.
        val adapter = Intent(context, NodesWidgetService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            data = android.net.Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
        }
        views.setRemoteAdapter(R.id.widget_list, adapter)
        views.setPendingIntentTemplate(R.id.widget_list, WidgetActions.selectTemplate(context))
        enable(views, R.id.widget_refresh, WidgetActions.measure(context).takeIf { snapshot.live })
        views.setOnClickPendingIntent(R.id.widget_open, WidgetActions.open(context))
        return views
    }

    fun nodeRow(
        context: Context,
        node: WidgetNode,
        selected: Boolean,
        group: String,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_node_item)
        views.setTextViewText(R.id.widget_item_name, node.name)
        views.setTextViewText(R.id.widget_item_delay, formatDelay(node.delay))
        views.setTextColor(
            R.id.widget_item_delay,
            context.getColor(delayGradeOf(node.delay).colorRes),
        )
        views.setViewVisibility(
            R.id.widget_item_mark,
            if (selected) View.VISIBLE else View.INVISIBLE,
        )
        views.setInt(
            R.id.widget_item_mark,
            colorFilter,
            context.getColor(R.color.widget_tone_active),
        )
        views.setOnClickFillInIntent(
            R.id.widget_item_root,
            WidgetActions.selectFillIn(group, node.name),
        )
        return views
    }

    private fun tint(context: Context, views: RemoteViews, snapshot: WidgetSnapshot) {
        val tone = context.getColor(snapshot.tone.colorRes)
        views.setInt(R.id.widget_orb, colorFilter, tone)
        views.setInt(R.id.widget_mark, colorFilter, tone)
    }

    // A Chronometer counts on its own once it knows when the session began, so
    // a live uptime costs no broadcasts at all.
    private fun uptime(views: RemoteViews, viewId: Int, snapshot: WidgetSnapshot) {
        if (snapshot.live && snapshot.startedAtMillis > 0L) {
            views.setChronometer(
                viewId,
                SystemClock.elapsedRealtime() - snapshot.uptimeMillis,
                null,
                true,
            )
        } else {
            views.setChronometer(viewId, SystemClock.elapsedRealtime(), null, false)
        }
    }

    private fun enable(views: RemoteViews, viewId: Int, intent: PendingIntent?) {
        views.setOnClickPendingIntent(viewId, intent)
        views.setBoolean(viewId, "setEnabled", intent != null)
        views.setInt(viewId, imageAlpha, if (intent != null) opaque else dimmed)
    }

    private fun visibility(visible: Boolean) = if (visible) View.VISIBLE else View.GONE

    private fun title(context: Context, snapshot: WidgetSnapshot): CharSequence =
        snapshot.profile.takeIf { it.isNotBlank() }?.let { shorten(it, 22) }
            ?: context.getText(R.string.widget_app_name)

    private fun switchDetail(context: Context, snapshot: WidgetSnapshot): CharSequence {
        if (!snapshot.live) return context.getText(snapshot.modeRes)
        val mode = context.getString(snapshot.modeRes)
        val node = snapshot.node.takeIf { it.isNotBlank() }?.let { shorten(it, 16) }
        return listOfNotNull(mode, node).joinToString(separator)
    }

    // The header already names the run state, so the subtitle carries what it
    // cannot: which engine is up and where it is pointed.
    private fun statusSubtitle(context: Context, snapshot: WidgetSnapshot): CharSequence {
        if (!snapshot.live) return context.getText(R.string.widget_service_off)
        val mode = context.getString(snapshot.modeRes)
        val node = snapshot.node.takeIf { it.isNotBlank() }?.let { shorten(it, 18) }
        val delay = formatDelay(snapshot.delay).takeIf { it.isNotBlank() }
        return listOfNotNull(mode, node, delay).joinToString(separator)
            .ifBlank { context.getString(R.string.widget_state) }
    }

    private fun nodesTitle(context: Context, snapshot: WidgetSnapshot): CharSequence =
        snapshot.group.takeIf { it.isNotBlank() }?.let { shorten(it, 22) }
            ?: context.getText(R.string.widget_label_nodes)
}
