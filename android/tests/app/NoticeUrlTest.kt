package com.reclash

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class NoticeUrlTest {

    @Test
    fun `a web link is opened as the panel wrote it, trimmed`() {
        assertEquals("https://panel.test/renew", openableUrl(" https://panel.test/renew\n"))
        assertEquals("http://panel.test", openableUrl("http://panel.test"))
        assertEquals("https://panel.test", openableUrl("HTTPS://panel.test"))
    }

    @Test
    fun `a scheme that could reach another app is refused`() {
        assertNull(openableUrl("intent://scan/#Intent;scheme=zxing;end"))
        assertNull(openableUrl("file:///data/data/com.reclash"))
        assertNull(openableUrl("javascript:alert(1)"))
        assertNull(openableUrl("panel.test/renew"))
        assertNull(openableUrl("https://panel.test/a b"))
    }

    @Test
    fun `a link without a host is refused`() {
        assertNull(openableUrl("https://"))
        assertNull(openableUrl(""))
        assertNull(openableUrl(null))
    }
}
