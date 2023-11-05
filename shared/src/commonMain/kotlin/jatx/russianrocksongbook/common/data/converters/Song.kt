package jatx.russianrocksongbook.common.data.converters

import io.ktor.http.encodeURLPath
import jatx.russianrocksongbook.common.domain.models.Song
import jatx.russianrocksongbook.db.SongEntity

fun Song.toSongEntity() = SongEntity(
    id = id ?: 0,
    artist = artist,
    title = title,
    text = text,
    favorite = if (favorite) 1 else 0,
    deleted = if (deleted) 1 else 0,
    outOfTheBox = if (outOfTheBox) 1 else 0,
    origTextMD5 = origTextMD5
)

fun SongEntity.toSong() = Song(
    id = id,
    artist = artist,
    title = title,
    text = text,
    favorite = (favorite != 0L),
    deleted = (deleted != 0L),
    outOfTheBox = (outOfTheBox != 0L),
    origTextMD5 = origTextMD5
)

val Song.yandexMusicUrl: String
    get() {
        val searchForEncoded = "$artist $title"
            .encodeURLPath()
        return "https://music.yandex.ru/search?text=$searchForEncoded"
    }