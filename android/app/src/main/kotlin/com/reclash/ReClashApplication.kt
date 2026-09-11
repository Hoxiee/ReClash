package com.reclash

import android.app.Application
import android.content.Context
import com.reclash.common.GlobalState
import com.reclash.widgets.WidgetPump

class ReClashApplication : Application() {
    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }

    override fun onCreate() {
        super.onCreate()
        WidgetPump.wake(this)
    }
}
