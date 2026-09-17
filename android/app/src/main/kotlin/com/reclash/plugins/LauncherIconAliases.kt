package com.reclash.plugins

internal object LauncherIconAliases {
    const val defaultAlias = ".icons.DefaultAlias"

    val currentAliases = mapOf(
        "default" to defaultAlias,
        "velvet" to ".icons.VelvetAlias",
        "solar" to ".icons.SolarAlias",
        "circuit" to ".icons.CircuitAlias",
        "echo" to ".icons.EchoAlias",
        "ink" to ".icons.InkAlias",
        "blueprint" to ".icons.BlueprintAlias",
        "mesh" to ".icons.MeshAlias",
        "facet" to ".icons.FacetAlias",
        "strata" to ".icons.StrataAlias",
        "shatter" to ".icons.ShatterAlias",
        "trace" to ".icons.TraceAlias",
        "vigil" to ".icons.VigilAlias",
        "topo" to ".icons.TopoAlias",
        "spark" to ".icons.SparkAlias",
        "fractal" to ".icons.FractalAlias",
    )

    val allAliases = currentAliases.values.toSet()

    fun targetFor(variant: String): String? = currentAliases[variant]

    fun aliasesToDisable(variant: String): Set<String> {
        val target = targetFor(variant) ?: return emptySet()
        return allAliases - target
    }
}
