package jatx.russianrocksongbook.common.networking

import kotlinx.serialization.Serializable

@Serializable
data class ResultWithCloudSongListData(
    val status: String,
    val message: String? = null,
    val data: List<CloudSong>? = null
)