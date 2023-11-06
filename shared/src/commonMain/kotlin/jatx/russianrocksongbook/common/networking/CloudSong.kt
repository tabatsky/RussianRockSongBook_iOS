package jatx.russianrocksongbook.common.networking

import jatx.russianrocksongbook.common.domain.models.Music
import jatx.russianrocksongbook.common.domain.models.Song
import jatx.russianrocksongbook.common.domain.models.TYPE_CLOUD
import jatx.russianrocksongbook.common.domain.models.USER_SONG_MD5
import jatx.russianrocksongbook.common.domain.models.Warnable
import jatx.russianrocksongbook.common.domain.models.Warning
import jatx.russianrocksongbook.common.domain.models.songTextHash
import kotlinx.serialization.Serializable

@Serializable
data class CloudSong(
    val songId: Int = -1,
    val googleAccount: String,
    val deviceIdHash: String,
    val artist: String,
    val title: String,
    val text: String,
    val textHash: String,
    val isUserSong: Boolean,
    val variant: Int = -1,
    val raiting: Double = 0.0,
    val likeCount: Int = 0,
    val dislikeCount: Int = 0
): Music, Warnable {
    val visibleTitle: String
        get() = "$title${if (variant == 0) "" else " ($variant)"}"

    override val searchFor: String
        get() = "$artist $title"

    override fun warningWithComment(comment: String) = Warning(
        warningType = TYPE_CLOUD,
        artist = artist,
        title = title,
        variant = variant,
        comment = comment
    )
}

fun Song.asCloudSong() = CloudSong(
    googleAccount = "iOS_debug",
    deviceIdHash = "iOS_debug",
    artist = artist,
    title = title,
    text = text,
    textHash = songTextHash(text),
    isUserSong = origTextMD5 == USER_SONG_MD5
)

fun CloudSong.asSong() = Song(
    artist = artist,
    title = visibleTitle,
    text = text,
    favorite = true,
    outOfTheBox = true,
    origTextMD5 = songTextHash(text)
)