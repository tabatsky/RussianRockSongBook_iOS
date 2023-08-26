package jatx.russianrocksongbook.common.dbinit

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