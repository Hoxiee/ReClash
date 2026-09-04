package com.reclash.service

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ByeDpiProtectPolicyTest {

    @Test
    fun `no descriptor means no ack`() {
        assertFalse(ByeDpiProtectPolicy.shouldAck(emptyList()))
    }

    @Test
    fun `a failed protect means no ack`() {
        assertFalse(ByeDpiProtectPolicy.shouldAck(listOf(true, false)))
    }

    @Test
    fun `every descriptor protected means ack`() {
        assertTrue(ByeDpiProtectPolicy.shouldAck(listOf(true)))
    }
}
