package jatx.russianrocksongbook.common.networking

import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.utils.io.core.use
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

const val BASE_URL = "http://tabatsky.ru/SongBook/api/"
object Repository {
    suspend fun searchSongs(
        searchFor: String,
        orderBy: OrderBy
    ): ResultWithCloudSongListData {
        return KtorClient.httpClient.use {
            it.get("$BASE_URL/songs/search/$searchFor/${orderBy.orderBy}").body()
        }
    }

    fun test() = GlobalScope.launch {
        val result = searchSongs("", OrderBy.BY_ID_DESC)
        val data = result.data
        data?.forEach {
            with(it) { println("$artist - $title") }
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