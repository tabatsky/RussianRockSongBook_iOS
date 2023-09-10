package jatx.russianrocksongbook.common.networking

import kotlinx.serialization.Serializable

@Serializable
data class CloudSong(
    val songId: Int,
    val googleAccount: String,
    val deviceIdHash: String,
    val artist: String,
    val title: String,
    val text: String,
    val textHash: String,
    val isUserSong: Boolean,
    val variant: Int,
    val raiting: Double,
    val likeCount: Int,
    val dislikeCount: Int
)