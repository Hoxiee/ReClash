package com.reclash.service.modules

/// Each strategy sits behind its own `-A`, so the group before the first one stays empty:
/// a working site is passed through untouched, and the ladder is climbed only on a trigger.
internal val BYEDPI_LADDER: List<List<String>> = listOf(
    listOf("--split", "1"),
    listOf("--disorder", "1"),
    listOf("--fake", "-1", "--ttl", "8"),
    listOf("--oob", "1"),
    listOf("--tlsrec", "1+s"),
)

internal const val BYEDPI_LOOPBACK = "127.0.0.1"

internal const val BYEDPI_CACHE_TTL_SECONDS = 100800

private const val TRIGGERS = "torst,redirect,ssl_err,conn"

private const val AUTO_MODE = "s,o"

internal fun byeDpiArgs(
    port: Int,
    cacheFile: String? = null,
    protectPath: String? = null,
    cacheTtlSeconds: Int = BYEDPI_CACHE_TTL_SECONDS,
    ladder: List<List<String>> = BYEDPI_LADDER,
): List<String> = buildList {
    add("-i")
    add(BYEDPI_LOOPBACK)
    add("-p")
    add(port.toString())
    add("-u")
    add(cacheTtlSeconds.toString())
    if (cacheFile != null) {
        add("-y")
        add(cacheFile)
    }
    if (protectPath != null) {
        add("-P")
        add(protectPath)
    }
    ladder.forEach { strategy ->
        add("-A")
        add(TRIGGERS)
        add("-L")
        add(AUTO_MODE)
        addAll(strategy)
    }
}
