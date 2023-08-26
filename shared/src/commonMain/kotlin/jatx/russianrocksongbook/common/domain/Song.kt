package jatx.russianrocksongbook.common.domain

import jatx.russianrocksongbook.common.dbinit.SongGson
import jatx.russianrocksongbook.db.SongEntity
import org.kotlincrypto.hash.md.MD5
import kotlin.experimental.ExperimentalObjCName
import kotlin.native.ObjCName

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
    constructor(artist: String, songGson: SongGson):
            this(
                artist = artist,
                title = songGson.title,
                text = songGson.text,
                origTextMD5 = songTextHash(songGson.text)
            )

    constructor(songEntity: SongEntity):
            this(
                id = songEntity.id,
                artist = songEntity.artist,
                title = songEntity.title,
                text = songEntity.text,
                favorite = (songEntity.favorite != 0L),
                deleted = (songEntity.deleted != 0L),
                outOfTheBox = (songEntity.outOfTheBox != 0L),
                origTextMD5 = songEntity.origTextMD5
            )

    fun toSongEntity() = SongEntity(
        id ?: 0,
        artist,
        title,
        text,
        if (favorite) 1 else 0,
        if (deleted) 1 else 0,
        if (outOfTheBox) 1 else 0,
        origTextMD5
    )

    // for correct MutableStateFlow working
    override fun equals(other: Any?): Boolean {
        return super.equals(other) && other is Song && favorite == other.favorite
    }

    override fun hashCode(): Int {
        return super.hashCode() + (if (favorite) 1 else 0)
    }

    fun asString(): String {
        return toString()
    }
}

fun songTextHash(text: String): String {
    val preparedText =
        text.trim { it <= ' ' }.lowercase().replace("\\s+".toRegex(), " ")
    return MD5().apply { update(preparedText.encodeToByteArray()) }.digest().decodeToString()
}