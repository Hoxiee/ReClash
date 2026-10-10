package com.reclash.service.models

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

private fun cidrs(vararg entries: String): List<CIDR> = entries.map { it.toCIDR() }

private fun resolve(
    family: AddressFamily,
    base: List<CIDR>,
    excluded: List<CIDR>,
) = resolveFamilyRoutes(base, excluded, family).toSet()

class ResolveFamilyRoutesTest {
    @Test
    fun `empty base and no exclusions is the family default route`() {
        assertEquals(cidrs("0.0.0.0/0").toSet(), resolve(AddressFamily.V4, emptyList(), emptyList()))
        assertEquals(cidrs("::/0").toSet(), resolve(AddressFamily.V6, emptyList(), emptyList()))
    }

    @Test
    fun `excluding the whole family leaves no route`() {
        assertTrue(resolve(AddressFamily.V4, emptyList(), cidrs("0.0.0.0/0")).isEmpty())
        assertTrue(resolve(AddressFamily.V6, emptyList(), cidrs("::/0")).isEmpty())
    }

    @Test
    fun `a disjoint exclusion leaves the base untouched`() {
        assertEquals(
            cidrs("10.0.0.0/8").toSet(),
            resolve(AddressFamily.V4, cidrs("10.0.0.0/8"), cidrs("192.168.0.0/16")),
        )
    }

    @Test
    fun `excluding the upper half of the family keeps the lower half`() {
        assertEquals(
            cidrs("0.0.0.0/1").toSet(),
            resolve(AddressFamily.V4, emptyList(), cidrs("128.0.0.0/1")),
        )
    }

    @Test
    fun `excluding the lower half of a block keeps the upper half`() {
        assertEquals(
            cidrs("10.128.0.0/9").toSet(),
            resolve(AddressFamily.V4, cidrs("10.0.0.0/8"), cidrs("10.0.0.0/9")),
        )
    }

    @Test
    fun `overlapping exclusions are merged before subtraction`() {
        assertEquals(
            cidrs("128.0.0.0/1").toSet(),
            resolve(AddressFamily.V4, emptyList(), cidrs("0.0.0.0/2", "0.0.0.0/1")),
        )
    }

    @Test
    fun `disjoint exclusions that together cover the base leave nothing`() {
        assertTrue(
            resolve(AddressFamily.V4, cidrs("10.0.0.0/8"), cidrs("10.0.0.0/9", "10.128.0.0/9")).isEmpty(),
        )
    }

    @Test
    fun `a host exclusion removes a single v4 address`() {
        assertEquals(
            cidrs("10.0.0.1/32").toSet(),
            resolve(AddressFamily.V4, cidrs("10.0.0.0/31"), cidrs("10.0.0.0/32")),
        )
    }

    @Test
    fun `a host exclusion removes a single v6 address`() {
        assertEquals(
            cidrs("fd00::1/128").toSet(),
            resolve(AddressFamily.V6, cidrs("fd00::/127"), cidrs("fd00::/128")),
        )
    }

    @Test
    fun `an exclusion of the wrong family does not affect the result`() {
        assertEquals(
            cidrs("10.0.0.0/8").toSet(),
            resolveFamilyRoutes(cidrs("10.0.0.0/8"), emptyList(), AddressFamily.V4).toSet(),
        )
    }
}
