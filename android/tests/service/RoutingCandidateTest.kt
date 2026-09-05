package com.reclash.service.modules

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class RoutingCandidateTest {

    @Test
    fun `a network that has not reported capabilities cannot become the routing primary`() {
        val infos = mapOf(
            "fresh" to NetworkInfo(),
            "settled" to NetworkInfo(transport = "cellular"),
        )

        assertEquals("cellular", routingCandidate(infos) { 0 }?.transport)
    }

    @Test
    fun `a lone network without capabilities publishes nothing`() {
        assertNull(routingCandidate(mapOf("fresh" to NetworkInfo())) { 0 })
    }

    @Test
    fun `priority still orders the networks that have reported`() {
        val infos = mapOf(
            "cellular" to NetworkInfo(transport = "cellular"),
            "wifi" to NetworkInfo(transport = "wifi"),
        )

        val candidate = routingCandidate(infos) { entry ->
            if (entry.value.transport == "wifi") 0 else 4
        }

        assertEquals("wifi", candidate?.transport)
    }
}
