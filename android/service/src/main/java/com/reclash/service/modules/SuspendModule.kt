package com.reclash.service.modules

import com.reclash.core.Core
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

internal class SuspendModule(
    private val screenState: ScreenState,
    private val scope: CoroutineScope,
) : ServiceModule {
    private fun updateSuspension(snapshot: ScreenSnapshot) {
        Core.screenOff(!snapshot.screenOn)
        Core.suspended(!snapshot.screenOn && snapshot.deviceIdle)
    }

    override fun start() {
        scope.launch {
            screenState.state.collect(::updateSuspension)
        }
    }

    override fun stop() {
        Core.screenOff(false)
        Core.suspended(false)
    }
}
