package jatx.russianrocksongbook.android

import android.app.Application
import jatx.russianrocksongbook.common.db.DatabaseDriverFactory
import jatx.russianrocksongbook.common.di.Injector

class App : Application() {
    override fun onCreate() {
        super.onCreate()

        val factory = DatabaseDriverFactory(this)
        Injector.init(factory)
    }
}