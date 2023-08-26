package jatx.russianrocksongbook.common.res

actual object Resource {
    actual fun openRaw(raw: Raw): String {
        return raw.res.readText()
    }
}