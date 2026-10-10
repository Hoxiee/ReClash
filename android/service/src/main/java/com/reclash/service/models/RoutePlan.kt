package com.reclash.service.models

import java.math.BigInteger
import java.net.InetAddress

internal enum class AddressFamily(val bits: Int) {
    V4(32),
    V6(128),
    ;

    val byteCount: Int get() = bits / 8
    val max: BigInteger get() = BigInteger.ONE.shiftLeft(bits).subtract(BigInteger.ONE)
}

private data class Interval(val start: BigInteger, val end: BigInteger)

// resolveFamilyRoutes materializes the routes a VpnService.Builder should install
// for one family: the base set (an empty base means the whole family) minus the
// excluded set, reduced to the fewest disjoint CIDRs. A fully excluded family
// yields an empty list, which the caller must honor as "no route" rather than a
// default route.
internal fun resolveFamilyRoutes(
    base: List<CIDR>,
    excluded: List<CIDR>,
    family: AddressFamily,
): List<CIDR> {
    val baseIntervals = if (base.isEmpty()) {
        listOf(Interval(BigInteger.ZERO, family.max))
    } else {
        union(base.map { it.toInterval(family) })
    }
    val excludedIntervals = union(excluded.map { it.toInterval(family) })
    return baseIntervals
        .flatMap { subtract(it, excludedIntervals) }
        .flatMap { it.toCidrs(family) }
}

private fun CIDR.toInterval(family: AddressFamily): Interval {
    val value = BigInteger(1, address.address)
    val hostBits = family.bits - prefixLength
    val network = value.shiftRight(hostBits).shiftLeft(hostBits)
    val end = network.add(BigInteger.ONE.shiftLeft(hostBits)).subtract(BigInteger.ONE)
    return Interval(network, end)
}

private fun union(intervals: List<Interval>): List<Interval> {
    if (intervals.isEmpty()) return emptyList()
    val sorted = intervals.sortedBy { it.start }
    val merged = ArrayList<Interval>()
    var current = sorted.first()
    for (next in sorted.drop(1)) {
        if (next.start <= current.end.add(BigInteger.ONE)) {
            if (next.end > current.end) current = current.copy(end = next.end)
        } else {
            merged.add(current)
            current = next
        }
    }
    merged.add(current)
    return merged
}

private fun subtract(base: Interval, holes: List<Interval>): List<Interval> {
    val result = ArrayList<Interval>()
    var start = base.start
    for (hole in holes) {
        if (hole.end < start || hole.start > base.end) continue
        if (hole.start > start) {
            result.add(Interval(start, hole.start.subtract(BigInteger.ONE)))
        }
        val next = hole.end.add(BigInteger.ONE)
        if (next > start) start = next
        if (start > base.end) break
    }
    if (start <= base.end) {
        result.add(Interval(start, base.end))
    }
    return result
}

private fun Interval.toCidrs(family: AddressFamily): List<CIDR> {
    val cidrs = ArrayList<CIDR>()
    var start = start
    while (start <= end) {
        val maxHostBits = if (start.signum() == 0) family.bits else start.lowestSetBit
        var hostBits = minOf(maxHostBits, family.bits)
        while (hostBits > 0) {
            val blockEnd = start.add(BigInteger.ONE.shiftLeft(hostBits)).subtract(BigInteger.ONE)
            if (blockEnd <= end) break
            hostBits--
        }
        cidrs.add(CIDR(start.toInetAddress(family), family.bits - hostBits))
        start = start.add(BigInteger.ONE.shiftLeft(hostBits))
    }
    return cidrs
}

private fun BigInteger.toInetAddress(family: AddressFamily): InetAddress {
    val raw = toByteArray()
    val bytes = ByteArray(family.byteCount)
    val copy = minOf(raw.size, bytes.size)
    for (i in 0 until copy) {
        bytes[bytes.size - 1 - i] = raw[raw.size - 1 - i]
    }
    return InetAddress.getByAddress(bytes)
}
