package jatx.russianrocksongbook.common.dbinit

import jatx.russianrocksongbook.common.domain.models.Song
import jatx.russianrocksongbook.common.domain.models.songTextHash
import kotlinx.serialization.Serializable

@Serializable
data class SongBookGson(
    val songbook: List<SongGson>
)

@Serializable
data class SongGson(
    val title: String,
    val text: String
)

infix fun SongGson.asSongWithArtist(artist: String) = Song(
    artist = artist,
    title = title,
    text = text,
    origTextMD5 = songTextHash(text)
)