package jatx.russianrocksongbook.common.domain.models

import org.kotlincrypto.hash.md.MD5

const val USER_SONG_MD5 = "USER"

data class Song(
    var id: Long? = null,
    var artist: String = "",
    var title: String = "",
    var text: String = "",
    var favorite: Boolean = false,
    var deleted: Boolean = false,
    var outOfTheBox: Boolean = true,
    var origTextMD5: String = ""
) {
    // for correct MutableStateFlow working
    override fun equals(other: Any?): Boolean {
        return super.equals(other) && other is Song && favorite == other.favorite
    }

    override fun hashCode(): Int {
        return super.hashCode() + (if (favorite) 1 else 0)
    }

    val actualHash: String
        get() = songTextHash(text)

    val textWasChanged: Boolean
        get() = actualHash != origTextMD5
}

fun songTextHash(text: String): String {
    val preparedText =
        text.trim { it <= ' ' }.lowercase().replace("\\s+".toRegex(), " ")
    //println(preparedText)
    val md5 = MD5().apply { update(preparedText.encodeToByteArray()) }.digest().toHex()
    //println(md5)
    return md5
}

@OptIn(ExperimentalStdlibApi::class)
fun ByteArray.toHex(): String = joinToString(separator = "") { eachByte -> eachByte.toHexString() }