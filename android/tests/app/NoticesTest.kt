package com.reclash

import androidx.core.app.NotificationCompat
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class NoticesTest {
    @Test
    fun validatesNoticeActionUrls() {
        assertEquals("https://example.test/account", openableUrl(" https://example.test/account "))
        for (value in listOf(null, "", "https://user:secret@example.test", "https:///missing-host", "javascript:alert(1)", "file:///private", "https://example.test/line\nbreak")) {
            assertNull(openableUrl(value))
        }
    }

    @Test
    fun privateNoticesExposeOnlyPublicMessage() {
        assertEquals(NoticePrivacy(NotificationCompat.VISIBILITY_PRIVATE, "Subscription reminders"), noticePrivacy(true, "Subscription reminders"))
        assertEquals(NoticePrivacy(NotificationCompat.VISIBILITY_PUBLIC, null), noticePrivacy(false, "Subscription reminders"))
    }
}
