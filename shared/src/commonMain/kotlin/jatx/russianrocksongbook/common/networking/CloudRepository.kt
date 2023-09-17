package jatx.russianrocksongbook.common.networking

import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.utils.io.core.use
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

const val BASE_URL = "http://tabatsky.ru/SongBook2/api"
object CloudRepository {
    private suspend fun searchSongs(
        searchFor: String,
        orderBy: OrderBy
    ): ResultWithCloudSongListData {
        return KtorClient.newHttpClient().use {
            it.get("$BASE_URL/songs/search/$searchFor/${orderBy.orderBy}").body()
        }
    }

    fun searchSongsAsync(
        searchFor: String,
        orderBy: OrderBy,
        onSuccess: (List<CloudSong>) -> Unit,
        onError: (Throwable) -> Unit
    ) = GlobalScope.launch {
        try {
            val result = searchSongs(searchFor, orderBy)
            val data = result.data
            data?.let {
                onSuccess(it)
            }
        } catch (t: Throwable) {
            onError(t)
        }
    }
}

enum class OrderBy(
    val orderBy: String,
    val orderByRus: String
) {
    BY_ID_DESC("byIdDesc", "Последние добавленные"),
    BY_ARTIST("byArtist", "По исполнителю"),
    BY_TITLE("byTitle", "По названию")
}