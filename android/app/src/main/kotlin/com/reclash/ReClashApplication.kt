package com.reclash

import android.app.Application
import android.content.Context
import com.reclash.common.GlobalState
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class ReClashApplication : Application() {
    private var widgetObserver: Job? = null

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }

    override fun onCreate() {
        super.onCreate()
        widgetObserver?.cancel()
        widgetObserver = GlobalState.launch {
            ServiceState.runState.collectLatest { runState ->
                HomeWidgetProvider.updateAll(this@ReClashApplication, runState)
            }
        }
    }

    override fun onTerminate() {
        widgetObserver?.cancel()
        widgetObserver = null
        super.onTerminate()
    }
}
