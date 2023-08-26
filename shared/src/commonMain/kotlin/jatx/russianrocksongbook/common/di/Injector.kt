package jatx.russianrocksongbook.common.di

import jatx.russianrocksongbook.common.data.SongRepository
import jatx.russianrocksongbook.common.data.impl.SongRepositoryImpl
import jatx.russianrocksongbook.common.db.DatabaseDriverFactory
import jatx.russianrocksongbook.db.AppDatabase
import kotlin.concurrent.Volatile
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName
import kotlin.native.concurrent.ThreadLocal

class Injector(
    databaseDriverFactory: DatabaseDriverFactory
) {
    private val driver = databaseDriverFactory.createDriver()
    private val appDatabase = AppDatabase.invoke(driver)
    private val songRepo: SongRepository = SongRepositoryImpl(appDatabase)

    @ThreadLocal
    companion object {
        private var INSTANCE: Injector? = null

        val songRepo: SongRepository
            get() = INSTANCE!!.songRepo


        @OptIn(ExperimentalObjCName::class)
        @ObjCName(swiftName = "initiate")
        fun init(databaseDriverFactory: DatabaseDriverFactory) {
            INSTANCE = Injector(databaseDriverFactory)
        }
    }
}