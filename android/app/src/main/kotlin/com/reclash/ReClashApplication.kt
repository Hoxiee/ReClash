package com.reclash

import android.app.Application
import android.content.Context
import com.reclash.common.GlobalState

class ReClashApplication : Application() {
    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }
}
