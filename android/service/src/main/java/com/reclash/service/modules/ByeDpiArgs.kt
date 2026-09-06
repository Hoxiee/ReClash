package com.reclash.service.modules

internal const val BYEDPI_LOOPBACK = "127.0.0.1"

internal const val BYEDPI_CACHE_TTL_SECONDS = 100800

/// The app owns the listener, the per-network cache and the loop break, so they
/// lead and the user strategy follows: ciadpi's last-wins getopt lets a strategy
/// override them, and ByeByeDPI grants exactly that freedom.
internal fun byeDpiArgs(
    port: Int,
    strategy: List<String> = emptyList(),
    cacheFile: String? = null,
    protectPath: String? = null,
    cacheTtlSeconds: Int = BYEDPI_CACHE_TTL_SECONDS,
    cacheEnabled: Boolean = true,
): List<String> = buildList {
    add("-i")
    add(BYEDPI_LOOPBACK)
    add("-p")
    add(port.toString())
    add("-u")
    add(cacheTtlSeconds.toString())
    if (cacheEnabled && cacheFile != null) {
        add("-y")
        add(cacheFile)
    }
    if (protectPath != null) {
        add("-P")
        add(protectPath)
    }
    addAll(strategy)
}
