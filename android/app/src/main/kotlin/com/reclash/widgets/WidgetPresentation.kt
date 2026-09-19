package com.reclash.widgets

import com.reclash.R
import com.reclash.RunState
import com.reclash.toHomeWidgetPresentation

internal val WidgetTone.colorRes: Int
    get() = when (this) {
        WidgetTone.IDLE -> R.color.widget_tone_idle
        WidgetTone.PENDING -> R.color.widget_tone_pending
        WidgetTone.ACTIVE -> R.color.widget_tone_active
        WidgetTone.PAUSED -> R.color.widget_tone_paused
        WidgetTone.DEGRADED -> R.color.widget_tone_degraded
        WidgetTone.BROKEN -> R.color.widget_tone_broken
    }

internal val DelayGrade.colorRes: Int
    get() = when (this) {
        DelayGrade.NONE -> R.color.widget_on_surface_variant
        DelayGrade.GOOD -> R.color.widget_delay_good
        DelayGrade.MEDIUM -> R.color.widget_delay_medium
        DelayGrade.BAD -> R.color.widget_delay_bad
    }

// The switch widget owns the wording of every run state; the rest borrow it.
internal val WidgetSnapshot.statusRes: Int
    get() = runState.toHomeWidgetPresentation().statusRes

internal val WidgetSnapshot.modeRes: Int
    get() = when (mode) {
        WidgetMode.VPN -> R.string.widget_mode_vpn
        WidgetMode.BYEDPI -> R.string.widget_mode_byedpi
    }

internal val WidgetSnapshot.powerLabelRes: Int
    get() = runState.toHomeWidgetPresentation().actionLabelRes

internal val WidgetSnapshot.powerIconRes: Int
    get() = when (runState) {
        RunState.STARTED, RunState.STOPPING -> R.drawable.widget_ic_stop
        RunState.STARTING, RunState.STOPPED, RunState.PAUSED -> R.drawable.widget_ic_start
    }

internal val WidgetSnapshot.terrainRes: Int
    get() = when (terrain) {
        "normal" -> R.string.widget_terrain_normal
        "whitelist" -> R.string.widget_terrain_whitelist
        "portal" -> R.string.widget_terrain_portal
        "offline" -> R.string.widget_terrain_offline
        else -> R.string.widget_terrain_unknown
    }

// A stopped service has nothing to diagnose, so the last exam must not stick.
internal val WidgetSnapshot.doctorRes: Int
    get() = when {
        !live -> R.string.widget_doctor_observing
        doctorState == "examining" -> R.string.widget_doctor_examining
        doctorHealth == "healthy" -> R.string.widget_doctor_healthy
        doctorHealth == "degraded" -> R.string.widget_doctor_degraded
        doctorHealth == "broken" -> R.string.widget_doctor_broken
        else -> R.string.widget_doctor_observing
    }

internal val WidgetSnapshot.doctorToneRes: Int
    get() = when {
        !live -> R.color.widget_on_surface_variant
        doctorState == "examining" -> R.color.widget_tone_pending
        doctorHealth == "healthy" -> R.color.widget_delay_good
        doctorHealth == "degraded" -> R.color.widget_tone_degraded
        doctorHealth == "broken" -> R.color.widget_tone_broken
        else -> R.color.widget_on_surface_variant
    }
