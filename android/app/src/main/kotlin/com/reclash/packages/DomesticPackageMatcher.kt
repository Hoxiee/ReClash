package com.reclash.packages

import java.io.InputStream

/**
 * Prefixes match *without* a trailing dot boundary on purpose: `com.qihoo` has
 * to reach `com.qihoo360.*` and `com.ali` has to reach `com.aliyun.*`. Namespace
 * zones (`ru.`, `su.`, `ir.`) carry the dot in the entry itself, so the same
 * plain-prefix test treats them as a whole segment and never drags in `ruby.*`.
 *
 * Every signature layer is asset data now: `domestic/manifest.txt` lists the
 * shipped region codes, `domestic/skip.txt` the shared skip prefixes, and each
 * `domestic/<cc>/{apps,prefixes,sdk}.txt` the exact list (B), name prefixes (A),
 * and dex/class prefixes (C). Adding a region is a directory plus a manifest
 * line, never a `when` arm here.
 */
internal class DomesticPackageMatcher(
    private val openAsset: (String) -> InputStream,
) {

    private val listLock = Any()
    private val lists = HashMap<String, Set<String>>()

    /** Region codes that ship domestic data, from the shipped manifest. */
    val domesticRegions: Set<String> by lazy { list("domestic/manifest.txt") }

    fun isSkipped(packageName: String): Boolean = list("domestic/skip.txt").any {
        packageName == it || packageName.startsWith("$it.")
    }

    fun matchesExplicit(packageName: String, region: String): Boolean =
        list("domestic/$region/apps.txt").contains(packageName)

    fun matchesNamePrefix(packageName: String, region: String): Boolean =
        list("domestic/$region/prefixes.txt").any(packageName::startsWith)

    fun matchesClass(className: String, region: String): Boolean =
        list("domestic/$region/sdk.txt").any(className::startsWith)

    fun hasClassSignatures(region: String): Boolean =
        list("domestic/$region/sdk.txt").isNotEmpty()

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
            lines.map { it.substringBefore('#').trim().lowercase() }
                .filter(String::isNotEmpty)
                .toHashSet()
        }
    }.getOrDefault(emptySet())
}
