package com.reclash

import android.content.Intent
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class BootActionsTest {

    @Test
    fun `protected system boot broadcast is accepted`() {
        assertTrue(BootActions.isBoot(Intent.ACTION_BOOT_COMPLETED))
    }

    @Test
    fun `an app update restarts the tunnel the update killed`() {
        assertTrue(BootActions.isBoot(Intent.ACTION_MY_PACKAGE_REPLACED))
    }

    @Test
    fun `unrelated broadcasts never start anything`() {
        assertFalse(BootActions.isBoot(Intent.ACTION_PACKAGE_REPLACED))
        assertFalse(BootActions.isBoot("android.intent.action.QUICKBOOT_POWERON"))
        assertFalse(BootActions.isBoot("com.htc.intent.action.QUICKBOOT_POWERON"))
        assertFalse(BootActions.isBoot(Intent.ACTION_SCREEN_ON))
        assertFalse(BootActions.isBoot(""))
    }
}
