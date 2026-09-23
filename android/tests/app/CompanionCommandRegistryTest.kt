package com.reclash.companion

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CompanionCommandRegistryTest {
    private fun ok(tag: String): Map<String, Any?> = mapOf("status" to "succeeded", "tag" to tag)

    @Test
    fun `a retry replays the stored receipt without re-running the effect`() {
        val registry = CompanionCommandRegistry()
        var runs = 0
        val first = registry.resolve("c1", "e1", "r1", payloadHash = 42) { runs++; ok("first") }
        val second = registry.resolve("c1", "e1", "r1", payloadHash = 42) { runs++; ok("second") }

        assertTrue(first is CommandOutcome.Fresh)
        assertTrue(second is CommandOutcome.Replay)
        assertEquals("first", (second as CommandOutcome.Replay).result["tag"])
        assertEquals(1, runs)
    }

    @Test
    fun `same requestId with a different payload is a conflict`() {
        val registry = CompanionCommandRegistry()
        registry.resolve("c1", "e1", "r1", payloadHash = 42) { ok("first") }
        val outcome = registry.resolve("c1", "e1", "r1", payloadHash = 99) { ok("second") }

        assertTrue(outcome is CommandOutcome.Conflict)
    }

    @Test
    fun `a new epoch does not collide with the previous one`() {
        val registry = CompanionCommandRegistry()
        var runs = 0
        registry.resolve("c1", "e1", "r1", payloadHash = 42) { runs++; ok("e1") }
        val outcome = registry.resolve("c1", "e2", "r1", payloadHash = 42) { runs++; ok("e2") }

        assertTrue(outcome is CommandOutcome.Fresh)
        assertEquals(2, runs)
    }

    @Test
    fun `the ledger stays bounded and evicts the oldest receipt`() {
        val registry = CompanionCommandRegistry(maxPerEpoch = 2)
        registry.resolve("c1", "e1", "r1", payloadHash = 1) { ok("r1") }
        registry.resolve("c1", "e1", "r2", payloadHash = 2) { ok("r2") }
        registry.resolve("c1", "e1", "r3", payloadHash = 3) { ok("r3") }

        var reran = false
        val replayR1 = registry.resolve("c1", "e1", "r1", payloadHash = 1) { reran = true; ok("r1-again") }
        assertTrue(replayR1 is CommandOutcome.Fresh)
        assertTrue(reran)
    }

    @Test
    fun `the same requestId from different clients does not collide`() {
        val registry = CompanionCommandRegistry()
        var runs = 0
        registry.resolve("c1", "e1", "r1", payloadHash = 42) { runs++; ok("c1") }
        val outcome = registry.resolve("c2", "e1", "r1", payloadHash = 42) { runs++; ok("c2") }

        assertTrue(outcome is CommandOutcome.Fresh)
        assertEquals(2, runs)
    }

    @Test
    fun `a conflict never runs the effect`() {
        val registry = CompanionCommandRegistry()
        registry.resolve("c1", "e1", "r1", payloadHash = 42) { ok("first") }
        var reran = false
        val outcome = registry.resolve("c1", "e1", "r1", payloadHash = 99) { reran = true; ok("second") }

        assertTrue(outcome is CommandOutcome.Conflict)
        assertFalse(reran)
    }
}
