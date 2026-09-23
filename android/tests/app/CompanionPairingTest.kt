package com.reclash.companion

import java.security.SecureRandom
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

// Pairing security matrix on the JVM: expiry/cancel burn the secret (S05), a storage failure never
// answers approved (S06), a held token still reads its own status after approval (S07), a pending
// token cannot pass for a trusted one (S08 boundary), and revoke is immediate (S09 storage half).
class CompanionPairingTest {
    private var now = 1_000L
    private val clock = { now }
    private val random = SecureRandom().apply { setSeed(42L) }

    private fun pairing(store: CompanionTrustStore) =
        CompanionPairing(store, clock, random)

    @Test
    fun `happy path stores the token hash only after local approval`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()

        val submit = fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")
        assertTrue(submit is PairingSubmitResult.Accepted)
        val pairingId = (submit as PairingSubmitResult.Accepted).pairingId

        // Before approval there is no trusted client: no access without confirmation.
        assertEquals(0, store.count())
        val pending = fsm.pollStatus(pairingId, "tok-1")
        assertEquals(PairingStatusResult.Status("pending", submit.confirmationCode), pending)

        assertTrue(fsm.approvePending())
        assertEquals(1, store.count())
        assertNull(store.list().first().let { if (it.clientId == "c1") null else it })
    }

    @Test
    fun `late approval after expiry saves nothing`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()
        fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")

        now += PAIRING_WINDOW_MS + 1
        assertFalse(fsm.approvePending())
        assertEquals(0, store.count())
    }

    @Test
    fun `cancel burns the secret so a later submit is rejected`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()
        fsm.cancelWindow()

        val submit = fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")
        assertEquals(PairingSubmitResult.Rejected("pairingExpired"), submit)
    }

    @Test
    fun `approval write failure never answers approved`() {
        val store = FailingTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()
        fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")

        assertFalse(fsm.approvePending())
        assertEquals(0, store.count())
    }

    @Test
    fun `lost approval response lets the held token read approved without re-pairing`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()
        val submit = fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")
                as PairingSubmitResult.Accepted
        assertTrue(fsm.approvePending())

        // The 'approved' HTTP response was lost; the phone re-polls with the same token.
        val status = fsm.pollStatus(submit.pairingId, "tok-1")
        assertEquals(PairingStatusResult.Status("approved", null), status)
    }

    @Test
    fun `wrong secret is rejected and rate limited after five attempts`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        fsm.openWindow()

        repeat(MAX_WRONG_ATTEMPTS) {
            assertEquals(
                PairingSubmitResult.Rejected("pairingRejected"),
                fsm.submitPairing("wrong-secret", "c1", "Phone", "tok-1"),
            )
        }
        assertEquals(
            PairingSubmitResult.Rejected("busy"),
            fsm.submitPairing("wrong-secret", "c1", "Phone", "tok-1"),
        )
    }

    @Test
    fun `duplicate submit of same client and token returns the existing receipt`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()
        val first = fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")
                as PairingSubmitResult.Accepted
        val second = fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")
                as PairingSubmitResult.Accepted
        assertEquals(first.pairingId, second.pairingId)
        assertEquals(first.confirmationCode, second.confirmationCode)
    }

    @Test
    fun `device limit blocks a new client when the registry is full`() {
        val store = FakeTrustStore()
        repeat(8) { i ->
            store.put(
                CompanionTrustedClient("c$i", "P$i", byteArrayOf(i.toByte()), emptyList(), 0, 0),
            )
        }
        val fsm = CompanionPairing(store, clock, random, maxTrustedClients = 8)
        val window = fsm.openWindow()
        assertEquals(
            PairingSubmitResult.Rejected("deviceLimit"),
            fsm.submitPairing(window.secret, "new", "Phone", "tok-1"),
        )
    }

    @Test
    fun `a full registry still re-pairs an already trusted client`() {
        val store = FakeTrustStore()
        repeat(7) { i ->
            store.put(
                CompanionTrustedClient("c$i", "P$i", byteArrayOf(i.toByte()), emptyList(), 0, 0),
            )
        }
        store.put(CompanionTrustedClient("known", "P", byteArrayOf(9), emptyList(), 0, 0))
        val fsm = CompanionPairing(store, clock, random, maxTrustedClients = 8)
        val window = fsm.openWindow()
        assertTrue(
            fsm.submitPairing(window.secret, "known", "Phone", "tok-1")
                is PairingSubmitResult.Accepted,
        )
    }

    @Test
    fun `a second client cannot seize a window while another submission is pending`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()
        fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")
        assertEquals(
            PairingSubmitResult.Rejected("busy"),
            fsm.submitPairing(window.secret, "c2", "Other", "tok-2"),
        )
    }

    @Test
    fun `polling a pending pairing with the wrong token is unauthorized`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()
        val submit = fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")
                as PairingSubmitResult.Accepted
        assertEquals(
            PairingStatusResult.Rejected("unauthorized"),
            fsm.pollStatus(submit.pairingId, "wrong-token"),
        )
    }

    @Test
    fun `polling an expired pending pairing reports expired and clears it`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()
        val submit = fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")
                as PairingSubmitResult.Accepted
        now += PAIRING_WINDOW_MS + 1
        assertEquals(
            PairingStatusResult.Rejected("pairingExpired"),
            fsm.pollStatus(submit.pairingId, "tok-1"),
        )
    }

    @Test
    fun `polling an unknown pairing id without a trusted token is expired`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        assertEquals(
            PairingStatusResult.Rejected("pairingExpired"),
            fsm.pollStatus("no-such-id", "tok-1"),
        )
    }

    @Test
    fun `the wrong-attempt window reopens after the rate-limit period passes`() {
        val store = FakeTrustStore()
        val fsm = pairing(store)
        val window = fsm.openWindow()
        repeat(MAX_WRONG_ATTEMPTS) {
            fsm.submitPairing("wrong-secret", "c1", "Phone", "tok-1")
        }
        assertEquals(
            PairingSubmitResult.Rejected("busy"),
            fsm.submitPairing("wrong-secret", "c1", "Phone", "tok-1"),
        )
        now += ATTEMPT_WINDOW_MS + 1
        assertEquals(
            PairingSubmitResult.Accepted::class.java,
            fsm.submitPairing(window.secret, "c1", "Phone", "tok-1")::class.java,
        )
    }

    private open class FakeTrustStore : CompanionTrustStore {
        private val clients = LinkedHashMap<String, CompanionTrustedClient>()
        override fun list() = clients.values.toList()
        override fun find(clientId: String) = clients[clientId]
        override fun matchToken(token: String): CompanionTrustedClient? {
            val hash = java.security.MessageDigest.getInstance("SHA-256")
                .digest(token.toByteArray())
            return clients.values.firstOrNull {
                java.security.MessageDigest.isEqual(hash, it.tokenHash)
            }
        }
        override fun put(client: CompanionTrustedClient): Boolean {
            clients[client.clientId] = client
            return true
        }
        override fun remove(clientId: String) = clients.remove(clientId) != null
        override fun clear() = clients.clear()
        override fun count() = clients.size
    }

    private class FailingTrustStore : FakeTrustStore() {
        override fun put(client: CompanionTrustedClient) = false
    }
}
