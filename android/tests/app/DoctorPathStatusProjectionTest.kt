package com.reclash

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class DoctorPathStatusProjectionTest {

    @Test
    fun `duplicate projection is not published`() {
        val projection = DoctorPathStatusProjection { 1234L }

        val first = projection.update(DoctorPathKind.VPN, DoctorPathPhase.ACTIVE)
        val duplicate = projection.update(DoctorPathKind.VPN, DoctorPathPhase.ACTIVE)

        assertEquals(1L, first?.generation)
        assertEquals("vpn", first?.pathKind)
        assertEquals("active", first?.phase)
        assertEquals(1234L, first?.timestamp)
        assertNull(duplicate)
    }

    @Test
    fun `changed path state increments the shared generation`() {
        val projection = DoctorPathStatusProjection { 5678L }

        val active = projection.update(DoctorPathKind.VPN, DoctorPathPhase.ACTIVE)
        val paused = projection.update(DoctorPathKind.VPN, DoctorPathPhase.PAUSED)
        val proxy = projection.update(DoctorPathKind.LOCAL_PROXY, DoctorPathPhase.ACTIVE)

        assertEquals(1L, active?.generation)
        assertEquals(2L, paused?.generation)
        assertEquals(3L, proxy?.generation)
        assertEquals(5678L, active?.timestamp)
        assertEquals(5679L, paused?.timestamp)
        assertEquals(5680L, proxy?.timestamp)
        assertEquals("paused", paused?.phase)
        assertEquals("localProxy", proxy?.pathKind)
    }
}
