package jatx.russianrocksongbook.common.res

import dev.icerock.moko.resources.FileResource

expect object Resource {
    fun openRaw(res: FileResource): String
}