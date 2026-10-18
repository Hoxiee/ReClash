package com.reclash.packages

import java.io.InputStream
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap

internal class DomesticPackageMatcher(
    private val openAsset: (String) -> InputStream,
) {

    private val listLock = Any()
    private val lists = ConcurrentHashMap<String, Set<String>>()

    val domesticRegions: Set<String> by lazy { list("domestic/manifest.txt") }

    fun isSkipped(packageName: String): Boolean = list("domestic/skip.txt").any {
        packageName == it || packageName.startsWith("$it.")
    }

    fun matchesExplicit(packageName: String, region: String): Boolean =
        region in domesticRegions && list("domestic/$region/apps.txt").contains(packageName)

    fun matchesNamePrefix(packageName: String, region: String): Boolean =
        region in domesticRegions && list("domestic/$region/prefixes.txt").any(packageName::startsWith)

    fun matchesClass(className: String, region: String): Boolean {
        if (region !in domesticRegions) return false
        val normalizedClassName = className.lowercase(Locale.ROOT)
        return list("domestic/$region/sdk.txt").any(normalizedClassName::startsWith)
    }

    fun hasClassSignatures(region: String): Boolean =
        region in domesticRegions && list("domestic/$region/sdk.txt").isNotEmpty()

    fun classNameOf(descriptor: String): String = descriptor
        .removeSurrounding("L", ";")
        .replace('/', '.')
        .replace('$', '.')

    private fun list(assetPath: String): Set<String> {
        lists[assetPath]?.let { return it }
        return synchronized(listLock) {
            lists[assetPath] ?: loadList(assetPath).also { lists[assetPath] = it }
        }
    }

    private fun loadList(assetPath: String): Set<String> = runCatching {
        openAsset(assetPath).bufferedReader().useLines { lines ->
            lines.map { it.substringBefore('#').trim().lowercase(Locale.ROOT) }
                .filter(String::isNotEmpty)
                .toHashSet()
        }
    }.getOrDefault(emptySet())
}
