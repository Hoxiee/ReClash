package com.reclash.companion

import java.io.File
import java.nio.file.Files
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class CompanionTrustRegistryTest {
    private val dir: File = Files.createTempDirectory("companion-trust").toFile()
    private val file = File(dir, "pairings.json")

    @After
    fun cleanup() {
        dir.deleteRecursively()
    }

    private fun client(id: String, token: String) = CompanionTrustedClient(
        clientId = id,
        clientName = "Phone $id",
        tokenHash = java.security.MessageDigest.getInstance("SHA-256").digest(token.toByteArray()),
        scopes = COMPANION_DEFAULT_SCOPES,
        createdAtMs = 1L,
        lastSeenAtMs = 1L,
    )

    @Test
    fun `stored token hash survives reopening the file`() {
        CompanionFileTrustStore(file).put(client("c1", "tok-1"))
        val reopened = CompanionFileTrustStore(file)
        assertEquals(1, reopened.count())
        assertNotNull(reopened.matchToken("tok-1"))
        assertNull(reopened.matchToken("other"))
    }

    @Test
    fun `revoke removes the client immediately`() {
        val store = CompanionFileTrustStore(file)
        store.put(client("c1", "tok-1"))
        assertTrue(store.remove("c1"))
        assertNull(store.matchToken("tok-1"))
        assertEquals(0, store.count())
    }

    @Test
    fun `the raw token never appears in the persisted file`() {
        CompanionFileTrustStore(file).put(client("c1", "super-secret-token"))
        val text = file.readText()
        assertFalse(text.contains("super-secret-token"))
    }

    @Test
    fun `registry refuses a ninth client`() {
        val store = CompanionFileTrustStore(file, maxTrustedClients = 8)
        repeat(8) { assertTrue(store.put(client("c$it", "tok-$it"))) }
        assertFalse(store.put(client("c8", "tok-8")))
        assertEquals(8, store.count())
    }

    @Test
    fun `re-putting an existing client replaces in place and does not hit the limit`() {
        val store = CompanionFileTrustStore(file, maxTrustedClients = 8)
        repeat(8) { assertTrue(store.put(client("c$it", "tok-$it"))) }
        assertTrue(store.put(client("c0", "rotated-token")))
        assertEquals(8, store.count())
        assertNotNull(store.matchToken("rotated-token"))
        assertNull(store.matchToken("tok-0"))
    }

    @Test
    fun `default scopes survive a write and reopen round trip`() {
        CompanionFileTrustStore(file).put(client("c1", "tok-1"))
        val reopened = CompanionFileTrustStore(file).find("c1")
        assertNotNull(reopened)
        assertEquals(COMPANION_DEFAULT_SCOPES, reopened!!.scopes)
    }

    @Test
    fun `a corrupt registry file reads as empty rather than throwing`() {
        file.parentFile?.mkdirs()
        file.writeText("{ not json")
        val store = CompanionFileTrustStore(file)
        assertEquals(0, store.count())
        assertNull(store.matchToken("tok-1"))
    }
}
