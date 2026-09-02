package com.reclash

import android.app.Activity
import android.os.Bundle
import androidx.core.content.pm.ShortcutManagerCompat
import com.reclash.common.GlobalState
import com.reclash.common.QuickAction
import com.reclash.common.action
import kotlinx.coroutines.launch

class QuickActionActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        when (intent.action) {
            QuickAction.START.action -> GlobalState.launch { ServiceState.handleStartAction() }
            QuickAction.STOP.action -> GlobalState.launch { ServiceState.handleStopAction() }
            QuickAction.PAUSE.action -> GlobalState.launch { ServiceState.handlePauseAction() }
            QuickAction.RESUME.action -> GlobalState.launch { ServiceState.handleResumeAction() }
            QuickAction.TOGGLE.action -> {
                ShortcutManagerCompat.reportShortcutUsed(this, SHORTCUT_ID)
                GlobalState.launch { ServiceState.handleToggleAction() }
            }
        }
        finish()
    }

    private companion object {
        const val SHORTCUT_ID = "toggle"
    }
}
