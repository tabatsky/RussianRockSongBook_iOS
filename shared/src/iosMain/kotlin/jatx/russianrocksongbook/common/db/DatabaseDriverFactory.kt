package jatx.russianrocksongbook.common.db

import com.squareup.sqldelight.db.SqlDriver
import com.squareup.sqldelight.drivers.native.NativeSqliteDriver
import jatx.russianrocksongbook.db.AppDatabase

actual class DatabaseDriverFactory() {
    actual fun createDriver(): SqlDriver {
        return NativeSqliteDriver(AppDatabase.Schema, "test.db")
    }
}