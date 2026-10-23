package com.reclash.plugins

import android.content.pm.PackageManager
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class LauncherIconAliasesTest {
    @Test
    fun unknownKeysFallBackToStandard() {
        assertEquals("velvet", LauncherIconAliases.resolve("velvet"))
        assertEquals("standard", LauncherIconAliases.resolve("default"))
        assertEquals("standard", LauncherIconAliases.resolve(""))
    }

    @Test
    fun classNamesMatchManifestAliases() {
        assertEquals("com.reclash.icons.StandardAlias", LauncherIconAliases.className("standard"))
        assertEquals("com.reclash.icons.BlueprintAlias", LauncherIconAliases.className("blueprint"))
    }

    @Test
    fun onlyStandardShipsEnabled() {
        val default = PackageManager.COMPONENT_ENABLED_STATE_DEFAULT
        assertTrue(LauncherIconAliases.isEnabled("standard", default))
        assertFalse(LauncherIconAliases.isEnabled("spark", default))
        assertTrue(LauncherIconAliases.isEnabled("spark", PackageManager.COMPONENT_ENABLED_STATE_ENABLED))
        assertFalse(LauncherIconAliases.isEnabled("standard", PackageManager.COMPONENT_ENABLED_STATE_DISABLED))
    }

    @Test
    fun reportsStandardWhenNothingIsEnabled() {
        assertEquals("standard", LauncherIconAliases.current(emptySet()))
        assertEquals("topo", LauncherIconAliases.current(setOf("topo")))
    }

    @Test
    fun changeEnablesTargetAndDisablesTheRest() {
        assertNull(LauncherIconAliases.change("standard", setOf("standard")))
        assertEquals(
            LauncherIconAliases.Change("ink", listOf("standard")),
            LauncherIconAliases.change("ink", setOf("standard")),
        )
        assertEquals(
            LauncherIconAliases.Change(null, listOf("standard")),
            LauncherIconAliases.change("ink", setOf("standard", "ink")),
        )
    }
}
