package jatx.russianrocksongbook.common.networking

import io.ktor.client.call.body
import io.ktor.client.request.forms.submitForm
import io.ktor.client.request.get
import io.ktor.http.encodeURLPath
import io.ktor.http.parameters
import io.ktor.utils.io.core.use
import jatx.russianrocksongbook.common.domain.models.Warning
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString

const val BASE_URL = "http://tabatsky.ru/SongBook2/api"

@OptIn(DelicateCoroutinesApi::class)
object CloudRepository {
    private suspend fun searchSongs(
        searchFor: String,
        orderBy: OrderBy
    ): ResultWithCloudSongListData {
        return KtorClient.newHttpClient().use {
            it.get(
                "$BASE_URL/songs/search/$searchFor/${orderBy.orderBy}"
                    .encodeURLPath()
            ).body()
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
            } ?: run {
                println(result.message)
            }
        } catch (t: Throwable) {
            onError(t)
        }
    }

    private suspend fun vote(
        cloudSong: CloudSong,
        voteValue: Int
    ): ResultWithNumber {
        val googleAccount = "iOS_debug"
        val deviceIdHash = "iOS_debug"
        val artist = cloudSong.artist
        val title = cloudSong.title
        val variant = cloudSong.variant

        return KtorClient.newHttpClient().use {
            it.get(
                "$BASE_URL/songs/vote/$googleAccount/$deviceIdHash/$artist/$title/$variant/$voteValue"
                    .encodeURLPath()
            ).body()
        }
    }

    fun voteAsync(
        cloudSong: CloudSong,
        voteValue: Int,
        onSuccess: (Int) -> Unit,
        onServerMessage: (String) -> Unit,
        onError: (Throwable) -> Unit
    ) = GlobalScope.launch {
        try {
            val result = vote(cloudSong, voteValue)
            val data = result.data
            data?.let {
                onSuccess(it.toInt())
            } ?: run {
                onServerMessage(result.message ?: "null")
            }
        } catch (t: Throwable) {
            onError(t)
        }
    }

    private suspend fun addCloudSong(cloudSong: CloudSong): ResultWithoutData {
        return KtorClient.newHttpClient().use {
            it.submitForm(
                url = "$BASE_URL/songs/add",
                formParameters = parameters {
                    append("cloudSongJSON", Json.encodeToString(cloudSong))
                }
            ).body()
        }
    }

    fun addCloudSongAsync(
        cloudSong: CloudSong,
        onSuccess: () -> Unit,
        onServerMessage: (String) -> Unit,
        onError: (Throwable) -> Unit
    ) = GlobalScope.launch {
        try {
            val result = addCloudSong(cloudSong)
            result.message?.let {
                onServerMessage(it)
            } ?: run {
                onSuccess()
            }
        } catch (t: Throwable) {
            onError(t)
        }
    }

    private suspend fun addWarning(warning: Warning): ResultWithoutData {
        return KtorClient.newHttpClient().use {
            it.submitForm(
                url = "$BASE_URL/warnings/add",
                formParameters = parameters {
                    append("warningJSON", Json.encodeToString(warning))
                }
            ).body()
        }
    }

    fun addWarningAsync(
        warning: Warning,
        onSuccess: () -> Unit,
        onServerMessage: (String) -> Unit,
        onError: (Throwable) -> Unit
    ) = GlobalScope.launch {
        try {
            val result = addWarning(warning)
            result.message?.let {
                onServerMessage(it)
            } ?: run {
                onSuccess()
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