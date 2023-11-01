package jatx.russianrocksongbook.common.dbinit

import jatx.russianrocksongbook.common.domain.repository.SongRepository
import jatx.russianrocksongbook.common.di.Injector
import jatx.russianrocksongbook.common.domain.models.Song
import jatx.russianrocksongbook.common.res.Resource
import jatx.russianrocksongbook.MR
import kotlinx.serialization.json.Json

fun fillDBFromJSON() {
    fillDbFromJSON(Injector.songRepo) { progress, total ->
        println("$progress : $total")
    }
}

fun fillDbFromJSON(songRepo: SongRepository, onProgressChanged: (Int, Int) -> Unit) {
    val jsonLoader = JsonLoader()
    while (jsonLoader.hasNext()) {
        onProgressChanged(jsonLoader.current + 1, jsonLoader.total)
        val songs = jsonLoader.loadNext()
        songRepo.insertIgnoreSongs(songs)
    }
}

class JsonLoader() {
    var current = 0
    val total: Int
        get() = artists.size

    fun hasNext() = current < artists.size

    fun loadNext(): List<Song> {
        try {
            val artist = artists[current]
            val dict = artistMap[artist]

            current++

            dict?.apply {
                val jsonStr = Resource.openRaw(this)

                val songbook = Json.decodeFromString<SongBookGson>(jsonStr)

                return songbook.songbook.map { it asSongWithArtist artist }
            }
        } catch (e: Throwable) {
            e.printStackTrace()
        }

        return listOf()
    }
}

val artistMap = mapOf(
    "Агата Кристи" to MR.files.agata,
    "Алиса" to MR.files.alisa,
    "Би-2" to MR.files.bi2,
    "Високосный год" to MR.files.visokosniy,
    "ДДТ" to MR.files.ddt,
    "Кино" to MR.files.kino,
    "Наутилус Помпилиус" to MR.files.nautilus,
    "Немного Нервно" to MR.files.nervno
)

val artists = artistMap.keys.toTypedArray()