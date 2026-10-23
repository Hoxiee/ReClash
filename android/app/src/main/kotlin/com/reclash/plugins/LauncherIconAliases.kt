package com.reclash.plugins

import android.content.pm.PackageManager
import com.reclash.common.Components

internal object LauncherIconAliases {
    const val STANDARD = "standard"

    val keys = listOf(
        STANDARD,
        "velvet",
        "solar",
        "circuit",
        "echo",
        "ink",
        "blueprint",
        "strata",
        "shatter",
        "trace",
        "topo",
        "spark",
    )

    data class Change(val enable: String?, val disable: List<String>)

    fun resolve(key: String): String = key.takeIf(keys::contains) ?: STANDARD

    // The debug applicationId suffix does not change the manifest namespace.
    fun className(key: String): String =
        "${Components.PACKAGE_NAME}.icons.${key.replaceFirstChar(Char::titlecase)}Alias"

    // Only the standard alias ships enabled; untouched aliases report DEFAULT.
    fun isEnabled(key: String, state: Int): Boolean = when (state) {
        PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
        PackageManager.COMPONENT_ENABLED_STATE_DEFAULT -> key == STANDARD
        else -> false
    }

    fun current(enabled: Set<String>): String = keys.firstOrNull(enabled::contains) ?: STANDARD

    fun change(target: String, enabled: Set<String>): Change? {
        val enable = target.takeUnless(enabled::contains)
        val disable = keys.filter { it != target && it in enabled }
        return if (enable == null && disable.isEmpty()) null else Change(enable, disable)
    }
}
