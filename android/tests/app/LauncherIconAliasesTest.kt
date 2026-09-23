package com.reclash

import com.reclash.plugins.LauncherIconAliases
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test

class LauncherIconAliasesTest {
    @Test
    fun `every current target leaves all other launcher aliases disabled`() {
        val variants = setOf(
            "default",
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

        assertEquals(variants, LauncherIconAliases.currentAliases.keys)
        assertEquals(variants.size, LauncherIconAliases.allAliases.size)
        for (variant in variants) {
            val target = LauncherIconAliases.targetFor(variant)!!
            val aliases = LauncherIconAliases.aliasesToDisable(variant)

            assertFalse(aliases.contains(target))
            assertEquals(LauncherIconAliases.allAliases - target, aliases)
        }
    }

}
