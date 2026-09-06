package com.reclash.service.modules

internal const val BYEDPI_LOOPBACK = "127.0.0.1"

internal const val BYEDPI_CACHE_TTL_SECONDS = 100800

// Listener, cache and loop-break flags are app-owned; ciadpi's last-wins
// getopt would let a stray '-p' or '-i 0.0.0.0' override them.
private val APP_OWNED_WITH_VALUE = setOf(
    "-i", "--ip", "-p", "--port", "-y", "--cache-file", "-P", "--protect-path",
)

private val APP_OWNED_PREFIX = setOf("-i", "-p", "-y", "-P")

private val APP_OWNED_EQUALS_PREFIX = setOf(
    "--ip=", "--port=", "--cache-file=", "--protect-path=",
)

private val FORBIDDEN = setOf("-h", "--help", "-v", "--version")

internal fun stripAppOwnedArgs(
    strategy: List<String>,
    dropped: (String) -> Unit = {},
): List<String> = buildList {
    var skipValue = false
    for (token in strategy) {
        if (skipValue) {
            skipValue = false
            continue
        }
        if (token in APP_OWNED_WITH_VALUE) {
            skipValue = true
            dropped(token)
            continue
        }
        if (token in FORBIDDEN ||
            APP_OWNED_EQUALS_PREFIX.any { token.startsWith(it) } ||
            APP_OWNED_PREFIX.any { it.length == 2 && token.startsWith(it) && token.length > 2 }
        ) {
            dropped(token)
            continue
        }
        add(token)
    }
}

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
